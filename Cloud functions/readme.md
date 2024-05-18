**Ejemplo de archivo JSON  a enviar a la cloud function**
 
 URL cloud funtion: https://us-central1-testflutter-374414.cloudfunctions.net/test-cx

{

    "query":"MENSAJE USUARIO",  /Debe ser un string

    "sessionId":124, /Puede ser cualquier elemento, pero debemos llegar a una convención

    "userId":"1" /El userId debe ser un string, ya que firebase utiliza strings para los ids de las colecciones

}
