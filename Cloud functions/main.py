from google.cloud.dialogflowcx_v3 import SessionsClient
from google.cloud.dialogflowcx_v3 import AgentsClient
from google.cloud.dialogflowcx_v3.types import session 
from google.protobuf.json_format import MessageToDict


import firebase_admin
from firebase_admin import firestore
app = firebase_admin.initialize_app()
firestore_client = firestore.client()

from datetime import datetime
import pytz

import json
import uuid

import random
import string

#Esta función retorna la respuesta textual del agente en Dialogflow CX
def detect_intent_texts(agent, session_id, texts, language_code,user_id, habito):
    
    doc_ref = firestore_client.collection('usuarios').document(user_id)
    doc = doc_ref.get()
    d_firebase =  doc.to_dict()

    if(texts[0] == "Hola" and "session_id" not in d_firebase):
        doc_ref.update({"session_id":user_id})
    elif(texts[0] == "Hola" and "session_id" in d_firebase):
        added_id = ''.join(random.choices(string.ascii_letters + string.digits, k = 8))
        session_id = user_id + added_id
        doc_ref.update({"session_id":session_id})
    else:
        session_id = d_firebase["session_id"]

    #Si se usa el mismo session_id se mantiene la misma conversación, hasta por 1 hora máximo app
    session_path = f"{agent}/sessions/{session_id}"
    client_options = None
    agent_components = AgentsClient.parse_agent_path(agent)
    #Location depende de cada agente, esto se configuro en la función main
    location_id = agent_components["location"]
    if location_id != "global":
        api_endpoint = f"{location_id}-dialogflow.googleapis.com:443"
        print(f"API Endpoint: {api_endpoint}\n")
        client_options = {"api_endpoint": api_endpoint}
    session_client = SessionsClient(client_options=client_options)
    
    
    
    doc_ref = firestore_client.collection('usuarios').document(user_id)
    doc = doc_ref.get()
    d_firebase =  doc.to_dict()
    language_code = "es"

    #Revisión de hora actual y hora límite
    now = datetime.now(pytz.timezone("America/Santiago"))
    hora_actual = now.strftime("%H:%M")
    #d_final["hora_actual"] = hora_actual
    hor_limit_1 = now.replace(hour = 6, minute = 0, microsecond = 0)
    hor_limit_2 = now.replace(hour = 18, minute = 0, microsecond = 0)



#Guardar el mensaje que envío el usuario y lo configuramos en el formato requerido por la API de Dialogflow CX, al igual que el idioma
    for text in texts:
        text_input = session.TextInput(text=text)
        query_input = session.QueryInput(text=text_input, language_code=language_code)
        params = dict()


        if( "nombre" in d_firebase and "genero" in d_firebase and "universidad" in d_firebase):
            params = {"nombre":d_firebase["nombre"], "genero":d_firebase["genero"], "universidad": d_firebase["universidad"], "user_id":user_id}
            params["chat_inicial"] = 0
            subcoll = doc_ref.collections()
            params["instrumentos"] = 0
            for sub in subcoll:
                if(sub.id == "respuestas_iniciales"):
                    params["instrumentos"] = 1


            #Si el usuario envía el habito a practicar, enviamos los parametros asociados
            if("nombre" in habito):
                params["habito"] = habito["nombre"]
                params["planta"] = habito["planta"]
                params["horario"] = habito["horario"]
                params["id_habito"] = habito["id_habito"]
                params["etapa_actual"] = habito["etapa_actual"]
                riegos_ref = firestore_client.collection("usuarios").document(user_id).collection("habitos").document(habito["id_habito"]).collection(habito["etapa_actual"])
                riegos = riegos_ref.stream()
                dias = 0
                for riego in riegos:
                    dias += 1
                params["dia_etapa_actual"] = dias
                params["pedir_habito"] = 0

             
        else:
            params["chat_inicial"] = 1

        if(params["chat_inicial"] == 0):
            habitos_ref = firestore_client.collection('usuarios').document(user_id).collection('habitos')
            habito_docs = habitos_ref.stream()
            params["hab_diurno"] = 0
            params["hab_nocturno"] = 0
            for habito_doc in habito_docs:
                habito = habito_doc.to_dict()
                if(habito["horario"] == "Diurno" and now >= hor_limit_1 and now <= hor_limit_2 and ("ult_riego" not in habito or ("ult_riego" in habito and habito["ult_riego"].date() < now.date()) )  ):
                    params["hab_diurno"] = 1
                if(habito["horario"] == "Nocturno" and (now <= hor_limit_1 or now >= hor_limit_2) and ("ult_riego" not in habito or ("ult_riego" in habito and habito["ult_riego"].date() < now.date()) ) ):
                    params["hab_nocturno"] = 1

        query_params = session.QueryParameters(parameters=params)
        request = session.DetectIntentRequest(
            session=session_path, query_input=query_input, query_params=query_params
        )

        #Llamar  a la función detect_intent proveída por dialogflowcx_v3
        response = session_client.detect_intent(request=request)

        #Crear un diccionario para almacenar la custom payload que nos envía el agente, si es que  hay
        d = dict()
        response_json = MessageToDict(response._pb)
        for i in response_json["queryResult"]["responseMessages"]:
            if("payload" in i):
                d = i


        #Separar cada mensaje como elemento de una lista, método alternativo, AÚN EN TESTEO!!!!!!!!!!!
        respuesta_alt = list()
        for x in response.query_result.response_messages:
            respuesta_alt.append(" ".join(x.text.text))


        if("" in respuesta_alt):
            respuesta_alt.remove("")


        #Lectura de parametros de la conversacion
        params_final = response_json["queryResult"]["parameters"]

        #Crear el diccionario final, en donde se almacena tanto la respuesta textual del agente, como la custom payload si es que existe
        d_final = dict()
        
        #Parametro para informar a la app que la conversación termino

        if(any("end_interaction" in x for x in response.query_result.response_messages)):
            d_final["end"] = 1
        else:
            d_final["end"] = 0


        #Payload por defecto vacía para un manejo más fácil desde la app
        default_payload = {"options":[]}
        if("payload" in d):
            d_final["payload"] = d["payload"]
        else:
            d_final["payload"] = default_payload
  
        

        #AÚN EN TESTEO!!!!!!!!!!!!
        d_final["respuesta_alt"] = respuesta_alt
        

        d_final["statusCode"] = 200
        #Añadir los parametros a la respuesta para la app
        d_final["params"] = params_final

        #Actualizar los datos del usuario si es necesario
        user_update = dict()
        if("nombre" in d_final["params"]):
            user_update["nombre"] = d_final["params"]["nombre"]
        if("genero" in d_final["params"]):
            user_update["genero"] = d_final["params"]["genero"]
        if("universidad" in d_final["params"]):
            user_update["universidad"] = d_final["params"]["universidad"]
        if("correo" in d_final["params"]):
          user_update["correo"] = d_final["params"]["correo"]
        if("nacimiento" in d_final["params"]):
          user_update["nacimiento"] = d_final["params"]["nacimiento"]
        if("carrera" in d_final["params"]):
          user_update["carrera"] = d_final["params"]["carrera"]
        if("ano_carrera" in d_final["params"]):
          user_update["ano_carrera"] = d_final["params"]["ano_carrera"]

        if(user_update):
            doc_ref.update(user_update)



        #Almacenar en Firebase

        create_plant = dict()

        if all((k in params_final for k in ["horario","planta","habito"])) and "guardar_habito" in d_final["params"] and int(d_final["params"]["guardar_habito"]) == 1:
            habito_coll = doc_ref.collection("habitos")
            create_plant["etapa_actual"] = "germinacion"
            create_plant["horario"] = params_final["horario"]
            create_plant["planta"] = params_final["planta"]
            create_plant["nombre"] = params_final["habito"]
            habito_coll.document().set(create_plant)
            
        

        #Revisión de hora actual y hora límite
        now = datetime.now(pytz.timezone("America/Santiago"))
        hora_actual = now.strftime("%H:%M")
        #d_final["hora_actual"] = hora_actual
        hor_limit_1 = now.replace(hour = 6, minute = 0, microsecond = 0)
        hor_limit_2 = now.replace(hour = 18, minute = 0, microsecond = 0)



        #Generar el riego en Firebase y verificar si pasa a la siguiente etapa
        if("emocion" in d_final["params"] and "generar_riego" in d_final["params"] and d_final["params"]["generar_riego"] == 1):
            habito = firestore_client.collection("usuarios").document(user_id).collection("habitos").document(d_final["params"]["id_habito"])
            habito.update({"ult_riego":now})

            #Leer el documento de  tomate, para verificar los riegos necesarios para pasar a la siguiente etapa
            planta_ref = firestore_client.collection("plantas").document(d_final["params"]["planta"].lower())
            planta_doc = planta_ref.get()
            planta = planta_doc.to_dict()

                #Verificar si se puede pasar de germinacion a crecimiento
            if(d_final["params"]["etapa_actual"] == "germinacion"):
                riego = habito.collection("germinacion")
                riego.document().set({"fecha":now, "emocion":d_final["params"]["emocion"]})
                if( (int(d_final["params"]["dia_etapa_actual"]) + 1) == int(planta["riegos_germinacion"]) ):
                    habito.update({"etapa_actual":"crecimiento"})

                #Verificar si se puede pasar de crecimiento a reproduccion
            elif(d_final["params"]["etapa_actual"] == "crecimiento"):
                riego = habito.collection("crecimiento")
                riego.document().set({"fecha":now, "emocion":d_final["params"]["emocion"]})
                if( (int(d_final["params"]["dia_etapa_actual"]) + 1) == int(planta["riegos_crecimiento"]) ):
                    habito.update({"etapa_actual":"reproduccion"})

                #Verificar si se completo la etapa de reproduccion
            elif(d_final["params"]["etapa_actual"] == "reproduccion"):
                riego = habito.collection("reproduccion")
                riego.document().set({"fecha":now, "emocion":d_final["params"]["emocion"]})
                if( (int(d_final["params"]["dia_etapa_actual"]) + 1) == int(planta["reproduccion"]) ):
                    habito.update({"etapa_actual":"muerte"})



            




        #Enviar habitos disponibles a la app para que el usuario eliga el habito a practicar
        if("pedir_habito" in d_final["params"] and int(d_final["params"]["pedir_habito"]) == 1):
            habitos_ref = firestore_client.collection("usuarios").document(user_id).collection("habitos")
            habitos_docs = habitos_ref.stream()
            lista = list()
            for habito_doc in habitos_docs:
                habito = habito_doc.to_dict()
                habito["id_habito"] = habito_doc.id
                if(habito["horario"] == "Diurno" and now >= hor_limit_1 and now <= hor_limit_2 and ("ult_riego" not in habito or ("ult_riego" in habito and habito["ult_riego"].date() < now.date()) )  ):
                    if("ult_riego" in habito):
                        del habito["ult_riego"]
                    lista.append(habito)
                if(habito["horario"] == "Nocturno" and (now <= hor_limit_1 or now >= hor_limit_2) and ("ult_riego" not in habito or ("ult_riego" in habito and habito["ult_riego"].date() < now.date()) ) ):
                    if("ult_riego" in habito):
                        del habito["ult_riego"]
                    lista.append(habito)
            d_final["habitos_disponibles"] = lista
        else:
            d_final["habitos_disponibles"] = list()



        #Genera un json a partir del diccionario, y se codifica con ensure_ascci=False para no tener problemas con caracteres UTF-8
        respuesta_final = json.dumps(d_final, ensure_ascii= False)
        return respuesta_final
        


def main(request):
    request_json = request.get_json()
    #Los siguientes parametros se consiguen al revisar el nombre del agente en la consola de Dialogflow CX
    #Con el siguiente formato: projects/PROJECT_ID/locations/REGION_ID/agents/AGENT_ID
    project_id = "humanplace-nbhp"
    location_id = "us-central1"
    agent_id = "484eea5d-9f19-4704-876c-df30b7d5d398"
    #Se construye con los datos anteriores
    agent = f"projects/{project_id}/locations/{location_id}/agents/{agent_id}"
    
    #Recibir el session_id enviado en el json
    session_id = request_json["sessionId"]
    user_id = request_json["userId"]
    #Recibir el mensaje del usuario
    message = [request_json["query"]]
    

    habito = {"vacio":1}

    if("habito" in request_json):
        habito = request_json["habito"]


    language_code = "es"
    #Recibir datos de Firebase    
    
    respuesta = detect_intent_texts(agent, session_id, message, language_code,user_id,habito)
    return respuesta




