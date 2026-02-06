public class Data {
    " {begin} (Player) I heard a tip that they're in this bar. Surely, they're one of these robots, right? I've checked so many other buildings in the vicinity already...
    (Player) Since they uploaded their memory before they passed away, their robot counterpart must act like them, too.
    (Player) They say the best way to identify a robot clone is by replicating some interactions you both had together... Particularly, first interactions.
    (Player) I have to be careful, though. Robots are known to be predisposed to violence. This could get ugly for me if my cover is blown.
    (Player) So... who will be my first victim?
    (NPC:Sommelier) Oh, a new face. Are you new to the area? It's rare to see models like you around here.
    (NPC) Come right in. The patrons here are a motley crew, but they don't bite.
    (NPC:Tsundere) ...What are you looking at? Don't you know it's not polite to stare? Get the hell out of my face.
    (NPC:Sommelier) ...Regardless, this is a somewhat popular location: There's an urban legend that you'll find what you're looking for here...
    (NPC:Cleaner) But barkeep, you gotta control them! We got too many people coming in looking for love!
    (NPC:Sommelier) ...Anyways, can I get you started with anything?
    ? I'll have a ...
    - beer [beer]
    - shot [shot]
    - cocktail [cocktail]
    {beer} (NPC:Media) Barkeep, can I get another glass as well? I'll have whatever they're having!
    (NPC:Sommelier) Sure, two beers coming up. [resume]
    {shot} (NPC:Cleaner) A real partier, huh? Give 'em your strongest! Knock 'em out!
    (NPC:Sommelier) Ignore the heckling. One shot of motor oil for you coming up. [resume]
    {cocktail} (NPC:Tsundere) You should ask that they don't water down your drink... 
    (NPC:Sommelier) I definitely don't water down our drinks. You just seem to be building up a tolerance... [resume]
    {resume} (NPC:Sommelier) So, out of the three here, are any of them the one you're looking for?
    (Player) I'm not really looking for anyone in that way. Just here for a friendly drink.
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