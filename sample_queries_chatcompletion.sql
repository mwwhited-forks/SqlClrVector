/*

-- This script generates a chat completion using an external REST API call to an OpenAI model.
-- It prepares a system message and a user prompt, formats them as JSON, and sends them to the API.
-- The response from the API is then parsed to extract the chat completion content.

-- Variables:
-- @chat_completion: NVARCHAR(MAX) - Stores the final chat completion content.
-- @system_message: NVARCHAR(MAX) - Stores the system message to be sent to the API.
-- @user_promot: NVARCHAR(MAX) - Stores the user prompt to be sent to the API.
-- @model: NVARCHAR(MAX) - Specifies the model to be used for the chat completion.
-- @retval: INT - Stores the return value of the external REST endpoint invocation.
-- @response: NVARCHAR(MAX) - Stores the response from the external REST endpoint.
-- @max_tokens: INT - Specifies the maximum number of tokens for the chat completion.
-- @temperature: FLOAT - Specifies the temperature for the chat completion.
-- @url: VARCHAR(MAX) - Stores the URL for the external REST API endpoint.
-- @payload: NVARCHAR(MAX) - Stores the JSON payload to be sent to the API.

-- Steps:
-- 1. Set the system message and user prompt.
-- 2. Ensure the strings are valid for JSON by removing carriage returns and escaping double quotes.
-- 3. Construct the payload as a JSON string.
-- 4. Invoke the external REST endpoint using the constructed payload and headers.
-- 5. Parse the response to extract the chat completion content.
-- 6. Select the chat completion content for display.
*/

--- chat completion

DECLARE @chat_completion NVARCHAR(MAX);

DECLARE @system_message NVARCHAR(MAX);
set @system_message = N'Describe the message in English. It is a football match, and I am providing the detailed actions in Json format ordered minute by minute how action how they happenned.
By using the id, and related_events columns you can cross-relate events. There may be some hierachies. Mention the players in the script.
Do not invent any information. Do relate stick to the data. 
In special events like: goal sucessful, goal missed, shoots to goal, and goalkeeper saves relate like a commentator highlighting the action mentioning time, and score changes if apply.
Relate in prose format. Use the word keeper instead of goalkeeper. This is a portion of the event; it does not represent the whole match.
Do not make intro like "In the early moments of the match", "In the openning", etc. Just relate the action.
At the end include one sentence as a brief description of what happened starting with "Summary:"
This is the Json data: ';

DECLARE @user_promot NVARCHAR(MAX) = '
In the 84th minute of the match, Spain initiated a series of plays following a corner kick. Daniel Olmo Carvajal, positioned as a center attacking midfielder, executed a high pass from the center of the field, aimed at Lamine Yamal Nasraoui Ebana on the right wing. This pass traveled approximately 45 meters and was delivered with precision, landing at coordinates [106.8, 56.0].
As Spain maintained possession, Jude Bellingham from England applied pressure on the ball, attempting to disrupt Spains rhythm. Despite this, Nicholas Williams Arthuer of Spain quickly followed up with a short ground pass to Olmo, who was now under pressure from Marc Guehi, another England player. Olmo successfully received the ball and, despite being closely guarded, attempted to carry it forward.
However, Olmos dribble was incomplete as he faced pressure from Luke Shaw, who engaged in a tackle but lost the duel. Spains Nicholas Williams then recovered the ball, showcasing Spains resilience in maintaining possession. He carried the ball forward before being dispossessed by Olmo, who was again pressured by Declan Rice.
Spain continued to press forward, with Lamine Yamal Nasraoui Ebana taking the initiative to deliver a high inswinging corner kick. This attempt, however, was cleared by John Stones, who headed the ball away under pressure. Bukayo Saka also contributed to the defensive effort with a clearance of his own.
Fabián Ruiz Peña then recovered the ball for Spain, showcasing their ability to regain possession after the clearance. He carried the ball forward, navigating through pressure from Phil Foden, before passing it back to goalkeeper Unai Simón Mendibil. Simón, under pressure, managed to receive the ball and subsequently passed it to Marc Cucurella Saseta, who was positioned on the left.
Cucurella then carried the ball forward, looking to create an opportunity. He passed to Olmo, who received the ball and continued to advance. Lamine Yamal Nasraoui Ebana, now in a promising position, received the ball again and attempted to cross it towards Mikel Oyarzabal Ugarte. However, the cross was incomplete, leading to a ball receipt by Oyarzabal.
As the play unfolded, Englands goalkeeper Jordan Pickford collected the ball after a series of attempts from Spain, demonstrating the ongoing battle for possession in this intense match.
In the 85th minute of the match, Englands goalkeeper, Jordan Pickford, initiated a play by executing a ground pass with his arm to Kyle Walker, who was positioned at the right back. The pass traveled approximately 26 meters and reached Walker at coordinates [30.3, 62.1]. Walker received the ball cleanly and immediately began to carry it forward, moving under pressure from Spains Daniel Olmo Carvajal, who attempted to apply pressure on him.
Walker successfully dribbled past Olmo and continued his advance, carrying the ball to [37.0, 65.4]. He then made a short ground pass to Bukayo Saka, who was positioned on the right wing. Saka received the ball and carried it further to [37.5, 42.4]. Following this, Saka passed to John Stones, the right center back, who received the ball at [27.3, 59.0] and carried it forward to [29.2, 56.6].
Stones then executed a pass to Marc Guehi, the left center back, who received it at [27.9, 31.3]. Guehi carried the ball to [38.1, 21.3] before passing it to Declan Rice, the left defensive midfielder, who received it at [35.1, 32.1]. Rice then made a short pass back to Guehi, who received it at [34.8, 19.5] and carried it to [29.7, 11.6].
Guehi continued the play by passing back to Pickford, who received the ball at [13.6, 42.9]. Pickford then carried the ball forward to [14.7, 40.6] before passing it to Guehi again, who received it at [25.4, 17.4]. Guehi carried the ball to [29.7, 11.6] and then made a long pass to Ollie Watkins, who was positioned further up the field.
Watkins attempted to receive the ball but was unable to control it, resulting in an incomplete pass. Spains Daniel Carvajal then executed a throw-in to Aymeric Laporte, who received the ball at [25.1, 50.6]. Laporte carried the ball forward to [27.0, 43.8] before passing to Fabián Ruiz Peña, who received it at [49.3, 47.0].
Ruiz Peña then passed to Daniel Olmo, who received the ball at [63.4, 34.9]. Under pressure from Englands Cole Palmer, Olmo managed to carry the ball to [70.7, 33.6] before making a pass to Mikel Oyarzabal. Oyarzabal received the ball at [88.2, 39.9] and, after a quick carry, shot towards the goal, successfully scoring for Spain.
Jordan Pickford, in response to the shot, was unable to make a touch, resulting in a goal conceded. The sequence of events highlighted the fluidity of play, with both teams exhibiting pressure and quick transitions, culminating in Spains successful goal.
In the 87th minute of the match, England initiated a sequence of plays starting with Jude Bellingham carrying the ball from the right defensive midfield position. He advanced the ball to a location near the center of the pitch, ending his carry at coordinates [86.4, 40.4]. This play was part of a sequence that began from a kick-off.
Ollie Watkins, positioned as a center forward, then received a pass from Bellingham, which was a ground pass aimed towards Jordan Pickford, the goalkeeper. Pickford successfully received the ball and subsequently passed it to Bellingham again, who was now positioned further up the field.
Bellingham received the ball and attempted to pass it to Watkins, but the pass was incomplete. During this exchange, Nicholas Williams Arthuer from Spain engaged in an aerial duel but lost it, allowing England to maintain possession. Bellingham, under pressure, made another attempt to pass to Watkins, but this too was incomplete, leading to a ball recovery by Cole Palmer.
Palmer carried the ball forward, moving it to a location closer to the oppositions goal. He faced pressure from Fabián Ruiz Peña of Spain, who attempted to apply pressure on Palmer. Despite this, Palmer managed to pass the ball to Bellingham, who received it successfully.
As the play continued, Bellingham passed to Watkins, who was now in a more advanced position. Watkins carried the ball forward but miscontrolled it, leading to a moment of pressure from him as he tried to regain control. Spains José Ignacio Fernández Iglesias then executed a clearance under pressure, attempting to relieve the defensive pressure on his team.
This sequence highlighted Englands persistent attacking efforts, with Bellingham and Watkins playing crucial roles in maintaining possession and creating opportunities, while Spain struggled to defend against the mounting pressure.
';

-- Asegurar que las cadenas sean válidas para JSON
SET @system_message = REPLACE(REPLACE(@system_message, CHAR(13), ''), CHAR(10), '');
SET @system_message = REPLACE(@system_message, '"', '\"'); -- Escapar comillas dobles

SET @user_promot = REPLACE(REPLACE(@user_promot, CHAR(13), ''), CHAR(10), '');
SET @user_promot = REPLACE(@user_promot, '"', '\"'); -- Escapar comillas dobles

DECLARE @model NVARCHAR(MAX) = 'gpt-4o-mini';
DECLARE @retval INT, @response NVARCHAR(MAX);
DECLARE @max_tokens int = 1000;
DECLARE @temperature float = 0.1;
DECLARE @url VARCHAR(MAX) = 'https://xxxx.openai.azure.com/openai/deployments/' + @model + '/chat/completions?api-version=2023-05-15';
DECLARE  @payload NVARCHAR(MAX);

SET @payload = N'{"messages": [{"role": "system",' +
               N'"content": "' + @system_message + N'"},{"role": "user",' +
               N'"content": "' + @user_promot + N'"}],' +
               N'"temperature": ' + CAST(@temperature AS NVARCHAR(MAX)) + N',' +
               N'"max_tokens": ' + CAST(@max_tokens AS NVARCHAR(MAX)) +
               N'}';

-- difference: credential cannot be passed as parameter
EXEC dbo.sp_invoke_external_rest_endpoint2
    @url = @url,
    @method = 'POST',   
    @payload = @payload,   
    @headers = '{"Content-Type":"application/json", "api-key":"xxxx"}',
    @response = @response OUTPUT;

---- difference: SQL Azure sp_invoke_external_rest_endpoint returns: '$.result.choices[0].message.content'
-- SET @chat_completion = JSON_VALUE(@response, '$.result.choices[0].message.content');
set @chat_completion = CAST(JSON_VALUE(@response, '$.choices[0].message.content') AS NVARCHAR(MAX));

select @chat_completion AS Content;

GO