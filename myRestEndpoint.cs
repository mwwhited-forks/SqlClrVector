using System;
using System.Data.SqlTypes;
using System.IO;
using System.Net;
using System.Text;
using Microsoft.SqlServer.Server;

public class RestEndpoint
{
    [SqlProcedure]
    public static void InvokeRestEndpoint(SqlString url, SqlString method, SqlString payload, SqlString headersJson, out SqlString response)
    {
        response = new SqlString("Unknown error occurred."); // Valor inicial para el parámetro de salida

        try
        {
            // Forzar el uso de TLS 1.2
            System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            // (Opcional) Deshabilitar la validación de certificados (solo para pruebas)
            // System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            // Crear la solicitud HTTP
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url.Value);
            request.Method = method.Value.ToUpper();

            // Procesar encabezados desde JSON
            if (!headersJson.IsNull && !string.IsNullOrWhiteSpace(headersJson.Value))
            {
                // Remover las llaves iniciales y finales
                string trimmedHeaders = headersJson.Value.Trim('{', '}');
                string[] headerPairs = trimmedHeaders.Split(',');

                foreach (string pair in headerPairs)
                {
                    string[] keyValue = pair.Split(new char[] { ':' }, 2); // Dividir solo en el primer ':'
                    if (keyValue.Length == 2)
                    {
                        string key = keyValue[0].Trim().Trim('"');
                        string value = keyValue[1].Trim().Trim('"');

                        if (key.Equals("Content-Type", StringComparison.OrdinalIgnoreCase))
                        {
                            // Asignar Content-Type al encabezado de contenido
                            request.ContentType = value;
                        }
                        else
                        {
                            // Agregar otros encabezados a la solicitud
                            request.Headers.Add(key, value);
                        }
                    }
                }
            }

            // Configurar el payload para solicitudes POST
            if (method.Value.Equals("POST", StringComparison.OrdinalIgnoreCase) && !payload.IsNull)
            {
                byte[] byteArray = Encoding.UTF8.GetBytes(payload.Value);
                request.ContentLength = byteArray.Length;

                using (Stream dataStream = request.GetRequestStream())
                {
                    dataStream.Write(byteArray, 0, byteArray.Length);
                }
            }

            // Obtener la respuesta
            using (HttpWebResponse webResponse = (HttpWebResponse)request.GetResponse())
            {
                using (Stream dataStream = webResponse.GetResponseStream())
                {
                    using (StreamReader reader = new StreamReader(dataStream))
                    {
                        string responseFromServer = reader.ReadToEnd();
                        response = new SqlString(responseFromServer);
                    }
                }
            }
        }
        catch (WebException webEx)
        {
            if (webEx.Response != null)
            {
                using (var errorResponse = (HttpWebResponse)webEx.Response)
                {
                    using (var reader = new StreamReader(errorResponse.GetResponseStream()))
                    {
                        string errorText = reader.ReadToEnd();
                        response = new SqlString($"HTTP Error: {errorResponse.StatusCode} - {errorResponse.StatusDescription} - {errorText}");
                    }
                }
            }
            else
            {
                response = new SqlString($"WebException: {webEx.Message}");
            }
        }
        catch (Exception ex)
        {
            response = new SqlString($"Exception: {ex.GetType().Name} - {ex.Message} - {ex.StackTrace}");
        }
    }
}
