# How to Play Prop Hunt

Finally, hide-and-seek for the 31st century.

Each round, you will play as either a _hunter_ or a _prop_.  Prop players hide
by disguising themselves as inanimate objects ("props").  Hunters seek.

The hunters win if they kill all the props.  The props win if any props are
alive when the round timer runs out.


## Controls Cheat Sheet

| Key          | Team          | Action                                       |
| ------------ | ------------- | -------------------------------------------- |
| E            | Prop          | Become a copy of the selected object         |
| Right-click  | Prop          | Use powerup                                  |
| R            | Prop          | Lock rotation                                |
| T            | Prop          | Enable Tilting (pitch)                       |
| Left-shift   | Prop          | Hold breath (delay auto-taunt, lose health)  |
| Scroll wheel | Prop          | Rotate (roll)                                |
| F            | Hunter        | Flashlight                                   |
| Left-shift   | Hunter        | Look up or down based on nearest taunt       |
| Left-ctrl    | Both          | "Crouch" (allows for finer prop placement)   |
| Q            | Both          | Ramdomly taunt the other team                |
| Q (hold)     | Both          | Taunt slection menu (+ Ctrl for search)      |
| U            | Both          | Team chat                                    |
| C (hold)     | Both          | Context menu with various settings/actions   |
| F1           | Both          | Open the help window                         |
| F2           | Both          | Open the team selection window               |
| Space        | Spectator     | Cycle view mode (locked to player/free fly)  |


## Playing as a Prop

At the start of the round, find a disguise and hide before the hunters are
released.

Unfortunately for you, prop players are forced to _auto-taunt_ by playing a
random audio clip every so often.  The hunters will use this to narrow in on
your location.  There is a countdown in the bottom-right corner of the screen
showing how long before you are forced to auto-taunt.  If you taunt manually,
your timer resets—but shorter taunts buy you less time.

You can also hold your breath to delay the next auto-taunt at the cost of
quickly draining your health.

Don't stress if you are found; after you die, you can still taunt the hunters
to distract them.  However, you will not be able to taunt as frequently, so use
this power carefully when you are a ghost.

#### Power-ups

As a prop, you will start each round with a random single-use power-up.

 - **Blast Off**: shoot nearby hunters into the air
 - **Bong Cloud**: make a ton of smoke to escape
 - **Cloak**: temporarily become invisible
 - **Disguise**: temporarily become a hunter
 - **Friendly Fire**: temporarily enable friendly fire for the hunters
 - **Play Dead**: the next time you would take damage, only pretend to die
 - **Popup**: force nearby hunters to deal with a ton of popups
 - **Remove**: delete the selected prop
 - **Stack**: move the selected prop on top of yourself
 - **SUPER HOT**: slow down time for everyone but you
 - **Zoolander**: nearby hunters temporarily can't turn left
 - **Gun**: get a gun for a short time

#### Misc. Tips

 - Larger props have more health.  That means you can hold your breath longer
   as a huge prop!
 - While taunting you can see the outlines of other players through walls; make
   sure to note how close the hunters (outlined in red) are to you.
 - Locking your rotation makes it easier to hide, and it also resets your
   collision box.  Use rotation lock if you find yourself hovering above the
   ground suspiciously.
 - Move around!  Hunter players can be very good at narrowing in on you from
   your auto-taunts, so it's a good idea to be gone by the time they get there.
 - The "Unstick Prop" and "Reset To Spawn" context menu actions are meant to
   help you out when the game's physics engine gets you stuck inside another
   object.  Please don't abuse this power.


## Playing as a Hunter

Find the prop players by shooting stuff to test it!  Shooting a non-player prop
causes you to lose health.  Shooting a player prop restores your health.

Every hunter is randomly issued (1) either a pistol or a revolver, (2) either
an SMG or a shotgun, (3) one special weapon with a small amount of ammo, and
(4) one self-destruct.

#### SMG and Shotgun
The SMG and Shotgun both have an Alt-fire used by right-clicking.  The SMG will
fire a granade once per round and the shotgun will fire all of it's currently
loaded ammo in a wide spread.

#### Special Hunter Weapons

As a hunter you will be randomly given a small amount of either _taunt
grenades_ or _taunt seeker_ ammo to help you find props.

 - **Taunt Grenade**: forces nearby living props to taunt.  Even props that are
   holding their breath are forced to taunt.
 - **Taunt Seeker**: fires a slow, harmless projectile that moves roughly in
   the direction of an active taunt from a living prop.
 - **Thumper**: causes nearby non-player objects to jump in the air.  Prop
   players will remain stationary.
 - **Self Destruct**: right-click to use.  After a short fuse, you will
   explode!  In the event of a draw, hunters win—so don't be afraid to go for
   the Hail Mary.

#### Misc. Tips

 - Listen.  Auto-taunts are your main tool for locating hiding prop players.
   Headphones help!
 - Due to engine limitations, there is no up/down directional audio.  Use taunt
   seekers and the shift key to locate props hiding above or below you.
 - Work together.  The props will try to run when you find them, so keep doors
   closed and cover the exits.
 - Communicate.  Hunters with taunt seekers can tell if a taunt was from a
   ghost prop or not.  Hunters with taunt grenades can confirm if there is a
   prop in a cluttered room.
