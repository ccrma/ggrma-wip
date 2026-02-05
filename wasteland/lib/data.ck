public class Data {
    " {begin} (NPC) Welcome to the Wasteland!
    (NPC) The Wasteland is a place full of adventure and danger.
    (NPC) You will meet many characters along the way.
    (Player) ... where am I???
    (NPC) What do you feel?
    ? I feel ... towards robots.
    - fear [fear]
    - hate [hate]
    - love [love]
    {fear} (NPC) Fear is natural here. [resume]
    {hate} (NPC) Hate will consume you. [resume]
    {love} (NPC) Love is rare in the Wasteland. [resume]
    {resume} (Player) I see...
    (NPC) Good luck on your journey!
    ? Now I feel ...
    - brave [brave]
    - cautious [cautious]
    - lonely [lonely]
    - excited [excited]
    {brave} (NPC) Bravery will serve you well. [end]
    {cautious} (NPC) Caution is wise in these parts. [end]
    {lonely} (NPC) You are not alone here. [end]
    {excited} (NPC) Excitement fuels adventure! [end]
    {end} (NPC) Farewell, traveler. [begin]
    " => static string script;
}