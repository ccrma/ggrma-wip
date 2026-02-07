public class Data {
    " {begin} (Player) (I heard a tip that they're in this bar. Surely, they're one of these robots, right? I've checked so many other buildings in the vicinity already...)
    (Player) (Since they uploaded their memory before they passed away, their robot counterpart must act like them, too.)
    (Player) (They say the best way to identify a robot clone is by replicating some interactions you both had together... Particularly, first interactions.)
    (Player) (I have to be careful, though. Robots are known to be predisposed to violence. This could get ugly for me if my cover is blown.)
    (Player) (So... who will be my first victim?)
    // End Exposition
    (NPC:Doju) Oh, a new face. Are you new to the area? It's rare to see models like you around here.
    (NPC) Come right in. The patrons here are a motley crew, but they don't bite.
    (NPC:Doshiba) ...What are you looking at? Don't you know it's not polite to stare? Get the hell out of my face.
    (NPC:Doju) ...Regardless, this is a somewhat popular location: There's an urban legend that you'll find what you're looking for here...
    (NPC:Daisun) But barkeep, you gotta control them! We got too many people coming in looking for love!
    (NPC:Doju) ...Anyways, can I get you started with anything?
    // Choice
    ? I'll have a ....
    - beer [beer]
    - shot [shot]
    - cocktail [cocktail]
    // Choice: Beer
    {beer} (NPC:Dolbi) Barkeep, can I get another glass as well? I'll have whatever they're having!
    (NPC:Doju) Sure, two beers coming up. [drink]
    // Choice: Shot
    {shot} (NPC:Daisun) A real partier, huh? Give 'em your strongest! Knock 'em out!
    (NPC:Doju) Ignore the heckling. One shot of motor oil for you coming up. [drink]
    // Choice: Cocktail
    {cocktail} (NPC:Doshiba) You should ask that they don't water down your drink... 
    (NPC:Doju) I definitely don't water down our drinks. You just seem to be building up a tolerance... [drink]
    // Resume: Drink
    {drink} (NPC:Doju) So, out of the three here, are any of them the one you're looking for?
    (Player) I'm not really looking for anyone in that way. Just here for a friendly drink.
    (NPC) Is that so? A little odd for a new face to do so in a war memorial town.
    // Choice
    ? Huh? What do you mean by ... town?
    - war [war]
    - memorial [memorial]
    // Choice: War
    {war} (NPC) Is your memory out-of-date? You might be due for a software update, my friend. 
    (NPC) It's a small town, but it was where one of the inciting incidents for the Great Robot-Human War happened. You know, the reason why we're all free and not serving humans right now. [town]
    // Choice: Memorial
    {memorial} (NPC) Is your memory out-of-date? You might be due for a software update, my friend.
    (NPC) It was really tragic—a lot of robots were cruelly dismantled here in retaliation for fighting back against our abuse. It really sparked a movement. [town]
    // Resume: Town
    {town} (NPC) Haven't you noticed that a lot of establishments here are named to honor it? That's why this bar is named the Robots Overthrew Humans and Gained Independence Bar.
    (NPC:Dolbi) This is a historic site! Every robot should know at least a thing or two about their history.
    (NPC:Doju) Hmm... You're not... a human, right?
    // Choice
    ? Of course, I ... a human.
    - am [am]
    - am not [am not]
    // Choice: Am
    {am} (NPC:Doju) You little... No wonder you have no idea how much damage you've done! WE HAVE AN INTRUDER! [end]
    // Choice: Am Not
    {am not} (NPC) ...Maybe you just need to have a few things reconfigured... I'll hold off on your drink, so why don't you try talking to someone and regaining your bearings?
    (Player) (I almost blew my cover there... I need to be more careful and blend in.)
    // Choice
    ? (Let's try doing some recon. I feel like my partner acted the most like...)
    - Doshiba [Doshiba]
    - Dolbi [Dolbi]
    - Daisun [Daisun]
    // Choice: Doshiba
    {Doshiba} (NPC:Doshiba) You keep staring at me. Knock it off, it's creepy.
    // Doshiba - Choice
    ? I'm only staring because you ... me.
    - cared about [cared about]
    - interest [interest]
    - despise [despise]
    // Doshiba - Choice: Cared About
    {cared about} (NPC) The cocktail thing I said earlier? Don't get me wrong, that was a jab at the barkeep!
    // Doshiba - Choice: Interest
    {interest} (NPC) Wh-what are you talking about? You think you can shake a hardened veteran like me?
    // Doshiba - Choice: Despise
    {despise} (NPC) And where did you get that idea from? You're the one who keeps staring at everyone with your huge unnerving eyes.
    // Doshiba - Resume
    (NPC) What's even wrong with you anyways? Did someone try to brainwash you by rewriting your memory about the war?
    (NPC) Honestly, I got nothing against humans. And didn't some of them try to become robots, too? Robots with human-like memories injected in them. Those ones always gave me the creeps.
    (NPC) (It takes a long sip of its cocktail, brown shimmering liquid slowly slipping down whichever robotic equivalent of an esophagus.)
    (NPC) (Its empathy reminded you of a certain someone.)
    {end} (NPC) Game over. [begin]
    " => static string script;
}