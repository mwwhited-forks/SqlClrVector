using System;
using System.Data.SqlTypes;
using System.IO;
using System.Net;
using System.Text;
using Microsoft.SqlServer.Server;

public class RestEndpoint
{
    [SqlProcedure]
    public static void InvokeRestEndpoint(
        SqlString url, 
        SqlString method, 
        SqlString payload, 
        SqlString headersJson, 
        out SqlString response)
    {
        response = new SqlString("Unknown error occurred."); // Initial value for the output parameter

        try
        {
            // Force the use of TLS 1.2
            System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            // (Optional) Disable certificate validation (for testing only)
            // System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            // Create the HTTP request
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url.Value);
            request.Method = method.Value.ToUpper();

            // Process headers from JSON
            if (!headersJson.IsNull && !string.IsNullOrWhiteSpace(headersJson.Value))
            {
                // Remove the initial and final braces
                string trimmedHeaders = headersJson.Value.Trim('{', '}');
                string[] headerPairs = trimmedHeaders.Split(',');

                foreach (string pair in headerPairs)
                {
                    string[] keyValue = pair.Split(new char[] { ':' }, 2); // Split only at the first ':'
                    if (keyValue.Length == 2)
                    {
                        string key = keyValue[0].Trim().Trim('"');
                        string value = keyValue[1].Trim().Trim('"');

                        if (key.Equals("Content-Type", StringComparison.OrdinalIgnoreCase))
                        {
                            // Assign Content-Type to the content header
                            request.ContentType = value;
                        }
                        else
                        {
                            // Add other headers to the request
                            request.Headers.Add(key, value);
                        }
                    }
                }
            }

            // Set up the payload for POST requests
            if (method.Value.Equals("POST", StringComparison.OrdinalIgnoreCase) && !payload.IsNull)
            {
                byte[] byteArray = Encoding.UTF8.GetBytes(payload.Value);
                request.ContentLength = byteArray.Length;

                using (Stream dataStream = request.GetRequestStream())
                {
                    dataStream.Write(byteArray, 0, byteArray.Length);
                }
            }

            // Get the response
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

    [SqlProcedure]
    public static void InvokeOllamaModel(
        SqlString endpoint, 
        SqlString model, 
        SqlString prompt, 
        out SqlString response)
    {
        response = new SqlString("Unknown error occurred."); // Valor inicial del parámetro de salida

        try
        {
            // Forzar el uso de TLS 1.2
            System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            // Crear el payload
            string payload = $"{{\"model\": \"{model.Value}\", \"prompt\": \"{prompt.Value}\"}}";

            // Crear la solicitud HTTP
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(endpoint.Value);
            request.Method = "POST";
            request.ContentType = "application/json";

            byte[] byteArray = Encoding.UTF8.GetBytes(payload);
            request.ContentLength = byteArray.Length;

            using (Stream dataStream = request.GetRequestStream())
            {
                dataStream.Write(byteArray, 0, byteArray.Length);
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
