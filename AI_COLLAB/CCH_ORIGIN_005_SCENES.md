# CCH-ORIGIN-005 — The Second Year Remembers: every scene, choice and outcome

Generated from the game's own code by `tools/second_autumn_test.gd -- dump=AI_COLLAB/CCH_ORIGIN_005_SCENES.md`.
Each scene is shown as it came for the test's farm (bare unless noted), then each choice: what is written or done, the
sender's answer if any, and the diary as it stands after (the date first; no September page was written unless noted).

## A deposit on account

**Route** `a_deposit` · **The balance on your old account** · a letter · From the landlord of your old room

> This is the yearly statement we send on any balance left with us. 24 coins of your deposit are still on the account in your name, from the statement sent to you in the spring.
> 
> If you would like them, sign the slip below and send it back, and the money will be sent. Or write and tell us to close the account and keep the balance. If we hear nothing, the money stays where it is. Nothing is owed by you.

- **Sign the slip and send it back** (`sign`, reply)
  - Written: "Slip signed and returned."
  - Coins: 0 enclosed, 24 back with the answer
  - Their answer: "Thank you. The balance of 24 coins is enclosed. The account is closed."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The yearly statement for my old room came. The 24 coins of the deposit are still on the account. / October 7. / I signed the slip for the old deposit and sent it back. / October 14. They wrote back with the 24 coins. The account is closed.
- **Tell them to close it and keep the balance** (`close`, reply)
  - Written: "Please close the account and keep the balance. I won't be writing for it."
  - Their answer: "As you ask, the account is closed and the balance kept. Nothing more will be sent."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The yearly statement for my old room came. The 24 coins of the deposit are still on the account. / October 7. / I wrote that they could close the account and keep the 24 coins. / October 14. They wrote back. The account is closed, and they kept the balance.
- **File it with the farm's papers, unsigned** (`file`, note)
  - Nothing is sent. The money stays on their account, in your name. They don't need an answer.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The yearly statement for my old room came. The 24 coins of the deposit are still on the account. / October 7. / I put the yearly statement in with the farm's papers, unsigned. The 24 coins stay on the account.

## A boxes opened, sent on

**Route** `a_send_on` · **The old door** · a letter · From your friend, who kept the boxes

> I stopped asking at your old door at the end of August, as I said I would. Apart from the seed catalogue, nothing came.
> 
> The new tenant seems decent. If you like, I can give them the farm's address, and they can send anything straight up to you. Or we can leave it, and anything that comes goes back where it came from. A line either way will do.

- **Ask them to give the tenant the farm's address** (`tenant`, reply)
  - Written: "Please give the new tenant the farm's address. Thank you for asking at the door all summer."
  - Their answer: "Done. I gave them the address on a card, and they've put it by the door. That's the last I'll need to do."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person who kept my boxes wrote. They stopped asking at the old door at the end of August. / October 7. / I asked them to give the new tenant at the old room the farm's address. / October 14. They wrote back. The new tenant has the farm's address.
- **Say there's no need** (`leave`, reply)
  - Written: "There's no need. Anything that comes can go back. Thank you for asking at the door all summer."
  - Their answer: "All right. I'll leave it, then. Look after yourself up there."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person who kept my boxes wrote. They stopped asking at the old door at the end of August. / October 7. / I wrote that there was no need: anything that comes to the old room can go back. / October 14. They wrote back. They'll leave it.
- **Keep the letter without answering** (`keep`, note)
  - Nothing is sent. Nothing comes on from the old door unless you write.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person who kept my boxes wrote. They stopped asking at the old door at the end of August. / October 7. I kept their letter and didn't answer it.

## A boxes shut

**Route** `a_desk` · **The two notices** · desk

> The envelope from the old room is in the desk, with the two notices in it: the rent notice and the farm's. One was no longer useful when you left. You kept it anyway.
> 
> The two boxes that came up in March are still shut.
> 
> The roof still has its hole, and the wind still comes through the walls. The deed is still the town's.

- **Open the two boxes** (`open_boxes`, open)
  - Open it now. It takes no time.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A year on, I opened the two boxes from the old room.
- **File the old room's papers with the farm's** (`file`, note)
  - Both notices go in the drawer with the deed.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put the papers from the old room in with the farm's papers, under the deed.
- **Put the old rent notice on the fire** (`discard`, note)
  - The farm's notice stays. The rent notice goes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put the old rent notice on the fire. I kept the farm's.
- **Leave the envelope as it is** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I looked through the envelope from the old room and left it as it was.

## A papers kept in a drawer

**Route** `a_papers` · **Your papers, still in the drawer** · a letter · From your friend, who kept the boxes

> Your papers are still in my drawer: the rent book and the letters. I'm turning out the drawers before the winter, and I'd rather not keep someone else's papers another year.
> 
> I can post them, or put them in the stove. Or, if you'd rather, I'll keep them a while yet. Tell me which. I won't do anything until you do.

- **Ask them to post the papers** (`post`, reply)
  - Written: "Please post them. Thank you for keeping them this long."
  - Their answer: "Here they are: the rent book, and the letters, tied the way you left them. That's the drawer clear."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person who kept my boxes wrote. My papers are still in their drawer. / October 7. I asked them to post my papers. / October 14. Their letter came with my papers: the old rent book and my letters, tied with string.
- **Tell them to put them in the stove** (`burn`, reply)
  - Written: "You can put them in the stove. Thank you for keeping them this long."
  - Their answer: "Done. That's the last of it, really this time."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person who kept my boxes wrote. My papers are still in their drawer. / October 7. I told them to put my papers in the stove. / October 14. They wrote back. The papers are burned.
- **Ask them to keep them a while yet** (`keep`, reply)
  - Written: "Could you keep them a while longer? I'll write when I know."
  - Their answer: "All right. They'll stay in the drawer."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person who kept my boxes wrote. My papers are still in their drawer. / October 7. I asked them to keep my papers a while longer. / October 14. They wrote back. The papers stay in their drawer.

## B paid work

**Route** `b_paid` · **The year's accounts** · a letter · From someone at the old job

> The year's accounts are done. Your March check is in the file with your pencil marks, and the two days you marked were right. The office asked me to send you the slip below for your records: 20 coins paid in May, for three hours.
> 
> The manager asked whether we could write to you again if something like it comes up. I said I'd ask, and that you might say no.

- **Say they can ask, case by case** (`ask_first`, reply)
  - Written: "You can write if something comes up. I'll say yes or no each time."
  - Their answer: "Understood. Each time, then, and no is a fine answer."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They sent the slip for the March sheets, for my records. / October 7. / I wrote that they can ask if something comes up, and I'll say yes or no each time. / October 14. They wrote back. They'll ask each time, and no is an answer.
- **Say the March sheets were the last** (`last`, reply)
  - Written: "The March sheets were the last I'll do from here. Thank you for the slip."
  - Their answer: "Understood. I'll tell the manager. Good luck up there."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They sent the slip for the March sheets, for my records. / October 7. / I wrote that the March sheets were the last work I'd do for them. / October 14. They wrote back. They'll tell the manager.
- **File the slip; don't answer** (`file`, note)
  - Nothing is sent. Nobody writes about more work unless you answer.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They sent the slip for the March sheets, for my records. / October 7. / I filed the slip with the farm's papers and didn't answer.

## B paid, boundary

**Route** `b_paid` · **The year's accounts** · a letter · From someone at the old job

> The year's accounts are done. Your March check is in the file with your pencil marks, and the two days you marked were right. The office asked me to send you the slip below for your records: 20 coins paid in May, for three hours.
> 
> That's all. I know you'd rather not be asked for more, so I'm not asking.

- **Thank them for the slip** (`thank`, reply)
  - Written: "Thank you for the slip, and for not asking."
  - Their answer: "You're welcome. Good luck with the farm."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They sent the slip for the March sheets, for my records. / October 7. I wrote to thank them for the slip. / October 14. They wrote back: good luck with the farm.
- **File the slip; don't answer** (`file`, note)
  - Nothing is sent. There is nothing to answer.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They sent the slip for the March sheets, for my records. / October 7. / I filed the slip with the farm's papers and didn't answer.

## B method sent

**Route** `b_method` · **Your way, still** · a letter · From someone at the old job

> We used your way again on the September sheets. The person who started in the summer learned it from your letter; it's pinned up by the slip trays now.
> 
> I don't need anything. I thought you'd want to know it's still in use.

- **Say it's theirs now** (`theirs`, reply)
  - Written: "It's yours now. Change it however suits you."
  - Their answer: "We will. Thank you for it."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They still check the sheets my way. / October 7. I wrote that the method is theirs now, to change however suits them. / October 14. They wrote back: thank you for it.
- **Say they can write if it stops working** (`write_if`, reply)
  - Written: "If it stops working, write and I'll look."
  - Their answer: "I will, if it does. I hope it won't come to that."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They still check the sheets my way. / October 7. I wrote that they can write if the method stops working. / October 14. They wrote back. They'll write if it stops working.
- **Keep the letter** (`keep`, note)
  - Nothing is sent. They didn't ask for anything.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. They still check the sheets my way. / October 7. I kept their letter about the method.

## B declined

**Route** `b_closed` · **Your old desk** · a letter · From someone at the old job

> The person they took on for the summer has stayed. They have your old desk now. Your instruction sheet is still in the drawer there. We still go by it.
> 
> I only wanted to say the order book is in good hands, so you needn't think about it. No need to answer.

- **Write back with good wishes** (`wish`, reply)
  - Written: "Thank you for letting me know. I hope the new person settles in."
  - Their answer: "They have. Good luck with the farm."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. The person taken on for the summer has stayed, at my old desk. / October 7. I wrote back with good wishes for the new person. / October 14. They wrote back: the new person has settled in.
- **Keep the note** (`keep`, note)
  - Nothing is sent.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. The person taken on for the summer has stayed, at my old desk. / October 7. I kept their note.
- **Don't keep it** (`discard`, note)
  - Nothing is sent. The note goes on the fire.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Someone from the old job wrote. The person taken on for the summer has stayed, at my old desk. / October 7. I read their note and didn't keep it.

## B never answered

**Route** `b_desk` · **The old job's letters** · desk

> The last letter from the old job is in the desk. You finished the order you had promised and signed the last page.
> 
> They wrote again in the spring, about the March sheets. You didn't answer, and someone else did them.
> 
> The roof still has its hole, and the wind still comes through the walls.

- **Write a short line to close it** (`close`, reply)
  - Written: "I won't be taking on work from here. Thank you for asking, all the same."
  - Their answer: "Understood. All the best up there."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I wrote to the old job that I won't be taking on work from the farm. / October 14. They wrote back: all the best.
- **File their letters with the farm's papers** (`file`, note)
  - Nothing is sent.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I filed the letters from the old job with the farm's papers.
- **Leave them where they are** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I read the old job's letters again and left them where they were.

## C held to September

**Route** `c_held` · **The things, after September** · a letter · From the person you shared the house with

> It's October. You asked me to keep everything until the end of September, and I have. I need the hall cupboard now.
> 
> I can send your two boxes, your boots and papers and the books that were yours. The carrier is 20 coins. Or I can take them to the charity shop. The clock and the shelf books I'll keep, if that's all right.
> 
> Let me know by October 28. If I don't hear by then, they'll go to the charity shop.

- **Ask for your two boxes (20 coins)** (`send`, reply)
  - Written: "Please send my boxes. 20 coins for the carrier are in with this. Keep the clock and the shelf books."
  - Coins: 20 enclosed, 0 back with the answer
  - Their answer: "The carrier took your boxes on Monday. That's the cupboard clear. I'll keep the clock and the shelf books, as before."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the house I left. They kept everything until the end of September, as agreed, and need the cupboard now. / October 7. / I asked them to send my two boxes, with 20 coins for the carrier. / October 14. Their letter came with the carrier, and my two boxes from the old house. / October 14. I opened the boxes from the old house: my boots, my papers and my books.
- **Say they can give the boxes away** (`give`, reply)
  - Written: "Please take them to the charity shop, and keep the clock and the shelf books. Thank you for keeping it all this long."
  - Their answer: "I took them to the charity shop on Saturday. That's everything, I think."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the house I left. They kept everything until the end of September, as agreed, and need the cupboard now. / October 7. / I wrote that they could take my boxes to the charity shop, and keep the clock and the shelf books. / October 14. They wrote back. My boxes went to the charity shop.

## C writing now and then

**Route** `c_letter` · **A year, near enough** · a letter · From the person you shared the house with

> Nothing much to tell. It's a year since you went, near enough. The plum tree came good again, and I've been giving the plums away. Your boxes are still in the hall cupboard. I don't mind them there.
> 
> Write when you like.

- **Write back about the farm** (`farm`, reply)
  - Written: "It's a year here too. At the farm: the house much as it was, the roof with its hole, and nothing yet from the open ground."
  - Their answer: "Thank you for the news of the farm. Write again when you like."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the old house, about ordinary things. My boxes are still in their hall cupboard. / October 7. / I wrote back about the farm: the house much as it was, the roof with its hole, and nothing yet from the open ground. / October 14. They wrote back. Write again when I like.
- **Ask for your two boxes (20 coins)** (`send`, reply)
  - Written: "It's a year here too. Could you send my boxes now? 20 coins for the carrier are in with this."
  - Coins: 20 enclosed, 0 back with the answer
  - Their answer: "The carrier took your boxes on Monday. That's the cupboard clear. I'll keep the clock and the shelf books, as before."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the old house, about ordinary things. My boxes are still in their hall cupboard. / October 7. / I wrote asking them to send my two boxes now, with 20 coins for the carrier. / October 14. Their letter came with the carrier, and my two boxes from the old house. / October 14. I opened the boxes from the old house: my boots, my papers and my books.
- **Say you'll stop writing for a while** (`pause`, reply)
  - Written: "I'll stop writing for a while. Keep the boxes or give them away, whichever suits you."
  - Their answer: "All right. They'll stay in the cupboard unless I need the room."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the old house, about ordinary things. My boxes are still in their hall cupboard. / October 7. / I wrote that I'll stop writing for a while, and that they can keep my boxes or give them away. / October 14. They wrote back. My boxes stay in their cupboard unless they need the room.

## C never answered

**Route** `c_unanswered` · **The letter from the old house** · desk

> The letter from the old house is in the desk. In the spring they wrote that they'd keep your boxes in the hall cupboard, and the clock. You haven't written since.
> 
> The small notebook you brought is in your case: names, measurements, a few things worth remembering.

- **Ask for your two boxes (20 coins)** (`send`, reply)
  - Written: "It's a year now. Could you send my boxes? 20 coins for the carrier are in with this. Keep the clock."
  - Coins: 20 enclosed, 0 back with the answer
  - Their answer: "The carrier took your boxes on Monday. That's the cupboard clear. I'll keep the clock and the shelf books, as before."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I wrote asking for my two boxes, with 20 coins for the carrier. / October 14. Their letter came with the carrier, and my two boxes from the old house. / October 14. I opened the boxes from the old house: my boots, my papers and my books.
- **Say they can give the boxes away** (`give`, reply)
  - Written: "It's a year now. You can give my boxes away, and keep the clock. Thank you for keeping them."
  - Their answer: "I took them to the charity shop on Saturday. That's everything, I think."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I wrote that they can give my boxes away and keep the clock. / October 14. They wrote back. My boxes went to the charity shop.
- **Leave it as it is** (`leave`, note)
  - Nothing is sent. Your boxes stay in their cupboard.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I read their letter again and left it as it was.

## C closed, notebook

**Route** `c_keepsake` · **From the old house** · desk

> In the spring you settled who would keep what. The clock and the shelf books are theirs, and your boxes went to the charity shop. That was the last thing between you. The small parcel with the key is still wrapped.
> 
> The small notebook you brought is in your case: names, measurements, a few things worth remembering.
> 
> The roof still has its hole, and the wind still comes through the walls.

- **Unwrap the key** (`open_key`, open)
  - Open it now. It takes no time.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A year on, I unwrapped the key from the old house.
- **Add a line to the notebook** (`add`, note)
  - One line, about the house as it is.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I added a line to the notebook: the house much as it was, the roof with its hole.
- **Put it back in the case** (`case`, note)
  - It goes back where it was.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I looked through the notebook and put it back in my case.
- **Leave it all where it is** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I looked at what I brought from the old house and left it where it was.

## C private, held

**Route** `c_held` · **The things, after September** · a letter · From someone at the house you left

> It's October. You asked me to keep everything until the end of September, and I have. I need the hall cupboard now.
> 
> I can send your two boxes, your boots and papers and the books that were yours. The carrier is 20 coins. Or I can take them to the charity shop. The clock and the shelf books I'll keep, if that's all right.
> 
> Let me know by October 28. If I don't hear by then, they'll go to the charity shop.

- **Ask for your two boxes (20 coins)** (`send`, reply)
  - Written: "Please send my boxes. 20 coins for the carrier are in with this. Keep the clock and the shelf books."
  - Coins: 20 enclosed, 0 back with the answer
  - Their answer: "The carrier took your boxes on Monday. That's the cupboard clear. I'll keep the clock and the shelf books, as before."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the house I left. They kept everything until the end of September, as agreed, and need the cupboard now. / October 7. / I asked them to send my two boxes, with 20 coins for the carrier. / October 14. Their letter came with the carrier, and my two boxes from the old house. / October 14. I opened the boxes from the old house: my boots, my papers and my books.
- **Say they can give the boxes away** (`give`, reply)
  - Written: "Please take them to the charity shop, and keep the clock and the shelf books. Thank you for keeping it all this long."
  - Their answer: "I took them to the charity shop on Saturday. That's everything, I think."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A letter came from the house I left. They kept everything until the end of September, as agreed, and need the cupboard now. / October 7. / I wrote that they could take my boxes to the charity shop, and keep the clock and the shelf books. / October 14. They wrote back. My boxes went to the charity shop.

## C boxes sent, shut

**Route** `c_keepsake` · **From the old house** · desk

> In the spring you settled who would keep what. The two boxes from the old house came, and are still shut. The small parcel with the key is still wrapped.
> 
> The postcard you brought is in your case. One line on it is still unfinished.
> 
> The roof still has its hole, and the wind still comes through the walls.

- **Open the boxes from the old house** (`open_house_boxes`, open)
  - Open it now. It takes no time.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A year on, I opened the boxes from the old house.
- **Unwrap the key** (`open_key`, open)
  - Open it now. It takes no time.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A year on, I unwrapped the key from the old house.
- **Finish the unfinished line** (`finish`, note)
  - Nothing is sent. The line is finished on the card.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I finished the line on the postcard, in pencil. I didn't send it.
- **Leave the line unfinished** (`case`, note)
  - The line stays as it is.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I read the postcard again and left the line unfinished.
- **Leave it all where it is** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I looked at what I brought from the old house and left it where it was.

## D no contact

**Route** `d_photo` · **The photograph, a year on** · desk

> The photograph from the notice is in the desk, folded along the roofline. In the spring you folded it back without writing anything beside it.
> 
> In the picture: half the house behind trees, a fence nobody had mended, a patch of open ground.
> 
> Now: The roof still has its hole, and the wind still comes through the walls. The open ground beside the house is still open ground. You haven't been far from the house. The road down the hill is still there.

- **Add a note beside the photograph** (`note`, note)
  - Beside the photograph you write:  A year on: the house much as it was, the roof with its hole; nothing yet from the open ground.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. Beside the photograph I added a note, a year on: the house much as it was, the roof with its hole; nothing yet from the open ground.
- **File it with the farm notice** (`file`, note)
  - The photograph goes back with the notice it came in.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put the photograph back with the farm notice it came in.
- **Leave it as it was** (`leave`, note)
  - Nothing is written.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I looked at the photograph again and left it as it was.

## D wrote about a place

**Route** `d_photo` · **The photograph, a year on** · desk

> The photograph from the notice is in the desk, folded along the roofline. In the spring you wrote to your friend about it.
> 
> In the picture: half the house behind trees, a fence nobody had mended, a patch of open ground.
> 
> Now: The roof still has its hole, and the wind still comes through the walls. The open ground beside the house is still open ground. Half an hour down the hill road is Wicker Cove, which the picture didn't show. You've been down twice.

- **Add a note beside the photograph** (`note`, note)
  - Beside the photograph you write:  A year on: the house much as it was, the roof with its hole; nothing yet from the open ground; a village down the hill road, Wicker Cove.
  - Diary: October 2. A year ago I hadn't been down the hill road. I've been to Wicker Cove twice since. / October 7. Beside the photograph I added a note, a year on: the house much as it was, the roof with its hole; nothing yet from the open ground; a village down the hill road, Wicker Cove.
- **Copy the note into a letter to your friend** (`write`, reply)
  - Written: "A year on, here is what the picture left out: the house much as it was, the roof with its hole; nothing yet from the open ground; a village down the hill road, Wicker Cove."
  - Their answer: "In the spring you wrote about the village down the hill road, Wicker Cove. The picture has more in it now."
  - Diary: October 2. A year ago I hadn't been down the hill road. I've been to Wicker Cove twice since. / October 7. I copied my note into a letter to your friend: the house much as it was, the roof with its hole; nothing yet from the open ground; a village down the hill road, Wicker Cove. / October 14. They wrote back about my letter.
- **File it with the farm notice** (`file`, note)
  - The photograph goes back with the notice it came in.
  - Diary: October 2. A year ago I hadn't been down the hill road. I've been to Wicker Cove twice since. / October 7. I put the photograph back with the farm notice it came in.
- **Leave it as it was** (`leave`, note)
  - Nothing is written.
  - Diary: October 2. A year ago I hadn't been down the hill road. I've been to Wicker Cove twice since. / October 7. I looked at the photograph again and left it as it was.

## E order kept for collection

**Route** `e_collect` · **Your order, after September** · a letter · From the shop where you left an order

> The end of September has passed, and your order is still in the back with your name on it. We kept it as agreed.
> 
> We can still send it up: the balance and carriage come to 24 coins. Or we can cancel it and return your deposit of 12 coins. Please let us know by October 28. If we don't hear by then, we'll cancel it and send the deposit.

- **Have it sent (24 coins)** (`send`, reply)
  - Written: "Please send it on to the farm. The balance and carriage, 24 coins, are enclosed."
  - Coins: 24 enclosed, 0 back with the answer
  - Their answer: "Received with thanks. Your order has gone with the carrier."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The shop wrote. The order wasn't collected by the end of September; it's still in their back room. / October 7. I paid the 24 coins to have the order sent up. / October 14. The carrier brought the order from the shop, with their note. / October 14. I unwrapped the order.
- **Cancel it; ask for the deposit back** (`refund`, reply)
  - Written: "Please cancel the order and send my deposit back."
  - Coins: 0 enclosed, 12 back with the answer
  - Their answer: "Your order is cancelled. Your deposit of 12 coins is enclosed."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The shop wrote. The order wasn't collected by the end of September; it's still in their back room. / October 7. / I cancelled the order and asked for my deposit back. / October 14. They wrote back with my deposit, 12 coins.

## E meeting in the autumn

**Route** `e_meeting` · **Back for the autumn** · a letter · From the person you'd agreed to meet

> I'm back, as I said I'd be. I could do a Saturday in November, here, in the afternoon. I know it's a long way for you, and I can't do anything later in the year.
> 
> If you can't come, you could write instead. Or we can leave it. Either is all right.

- **Say you can't come; write what it was for** (`tell`, reply)
  - Written: "I can't come that far. What I wanted to tell you in person was that I might move away. I did, sooner than I said."
  - Their answer: "I wondered if it was that. Thank you for telling me, even this way."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person I'd agreed to meet wrote. They're back, and could meet on a Saturday in November, where they live. / October 7. / I wrote that I can't come, and what the meeting had been for: I'd meant to tell them I might move away. / October 14. They wrote back. They'd wondered if it was that.
- **Ask to write instead, now and then** (`letters`, reply)
  - Written: "I can't come in November. Could we write instead, now and then?"
  - Their answer: "Now and then, then. I'm not much of a letter writer, but I'll try."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person I'd agreed to meet wrote. They're back, and could meet on a Saturday in November, where they live. / October 7. / I wrote that I can't come in November, and asked if we could write instead. / October 14. They wrote back. We'll write now and then.
- **Leave it there** (`leave`, reply)
  - Written: "November won't work, and I don't know when I'll be back that way. Let's leave it there."
  - Their answer: "All right. Thank you for writing."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The person I'd agreed to meet wrote. They're back, and could meet on a Saturday in November, where they live. / October 7. / I wrote that November won't work, and left it there. / October 14. They wrote back: thank you for writing.

## E on next year's list

**Route** `e_desk` · **The closing date** · desk

> The notice for the farm is in the desk. You put it under a pile of papers on a Wednesday, and took it out again on the Thursday.
> 
> The seasonal work starts about now: six weeks, from October. You aren't down for a place this year. Your name is on their list for next year, and they write in August.
> 
> The roof still has its hole, and the wind still comes through the walls. The open ground beside the house is still open ground.

- **Keep their letter for August** (`keep`, note)
  - Nothing is sent. Your name stays on the list.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put their letter where I'll find it in August.
- **Write to take your name off the list** (`off`, reply)
  - Written: "Please take my name off the list for next year. Thank you for holding it."
  - Their answer: "Done. Good luck with the farm."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I wrote asking them to take my name off next year's list. / October 14. They wrote back. My name is off the list.
- **Write down how it ended** (`write_down`, note)
  - In the diary:  The seasonal work started this month. I wasn't down for a place; my name is on next year's list.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The seasonal work started this month. I wasn't down for a place; my name is on next year's list.
- **Put the notice away with the farm's papers** (`put_away`, note)
  - Nothing is sent.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put the farm notice away with the farm's papers.
- **Leave it where it is** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I read the farm notice again and left it where it was.

## E storage shut

**Route** `e_desk` · **The closing date** · desk

> The notice for the farm is in the desk. You put it under a pile of papers on a Wednesday, and took it out again on the Thursday.
> 
> The cartons from the unit came in the spring, and are still shut.
> 
> The roof still has its hole, and the wind still comes through the walls. The open ground beside the house is still open ground.

- **Open the cartons** (`open_unit`, open)
  - Open it now. It takes no time.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. A year on, I opened the cartons from the storage unit.
- **Write down how it ended** (`write_down`, note)
  - In the diary:  The cartons from the storage unit came in the spring. I haven't opened them.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The cartons from the storage unit came in the spring. I haven't opened them.
- **Put the notice away with the farm's papers** (`put_away`, note)
  - Nothing is sent.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put the farm notice away with the farm's papers.
- **Leave it where it is** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I read the farm notice again and left it where it was.

## E address kept

**Route** `e_desk` · **The closing date** · desk

> The notice for the farm is in the desk. You put it under a pile of papers on a Wednesday, and took it out again on the Thursday.
> 
> You never met. They moved in June, and you kept their new address.
> 
> The roof still has its hole, and the wind still comes through the walls. The open ground beside the house is still open ground.

- **Write a short line to the new address** (`write`, reply)
  - Written: "A year on, a short line from the farm. I hope the move went well."
  - Their answer: "Thank you. It did, mostly. The same to you, up there."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I wrote a short line to their new address. / October 14. They wrote back: the move went well, mostly.
- **Write down how it ended** (`write_down`, note)
  - In the diary:  We never met. They moved in June.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. We never met. They moved in June.
- **Put the notice away with the farm's papers** (`put_away`, note)
  - Nothing is sent.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I put the farm notice away with the farm's papers.
- **Leave it where it is** (`leave`, note)
  - Nothing changes.
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. I read the farm notice again and left it where it was.

## Two September closings, one scene (A deposit, signed)

- **(closing: keep)** (`keep`)
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The yearly statement for my old room came. The 24 coins of the deposit are still on the account. / October 7. / I signed the slip for the old deposit and sent it back. At the end of September I wrote, "I want to keep some part of my old life." This one I closed. / October 14. / They wrote back with the 24 coins. The account is closed.
- **(closing: unsettled)** (`unsettled`)
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know. / October 7. The yearly statement for my old room came. The 24 coins of the deposit are still on the account. / October 7. / I signed the slip for the old deposit and sent it back. At the end of September I wrote, "There are things from before that I haven't settled yet." This was one of them. It is settled now. / October 14. They wrote back with the 24 coins. The account is closed.

## The practical morning (six farms)

**Route** `world` · **A year's work** · morning

- **morning** (`inn`)
  - Written: "A year ago you hadn't been down the hill road. Since then you've mended the leak over the back room at the inn in Wicker Cove."
  - Diary: October 2. A year ago I hadn't been down the hill road. In June I mended the leak over the back room at the inn in Wicker Cove, for Edith Vale.
- **morning** (`house`)
  - Written: "A year ago the wind came through the walls of this house. Now the roof has new shingles and the windows have glass."
  - Diary: October 2. A year ago the wind came through the walls of the house. Now the roof has new shingles and the windows have glass.
- **morning** (`hewn`)
  - Written: "A year ago you had never hewn a plank. The workbench has made 7 since."
  - Diary: October 2. A year ago I had never hewn a plank. I've hewn 7 at the workbench since.
- **morning** (`asked`)
  - Written: "A year ago you didn't know anyone on the road past the farm. Maren has asked you for things since, and you brought them."
  - Diary: October 2. A year ago I didn't know anyone on the road past the farm. Maren has asked me for things since, and I brought them.
- **morning** (`cove`)
  - Written: "A year ago you hadn't been down the hill road. You've been to Wicker Cove 4 times since."
  - Diary: October 2. A year ago I hadn't been down the hill road. I've been to Wicker Cove 4 times since.
- **morning** (`farm`)
  - Written: "It is a year since you came up the lane. Most of the valley past the gate is still unfamiliar."
  - Diary: October 2. It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know.

