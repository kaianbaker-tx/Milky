# Milky — Game Design

*Kaian's plan for the game. Anything can change — this is just so we don't forget.*

## The idea

You play as **Milky the Milk Box**, inside a refrigerator.

## Levels

There are **two big levels**. There's a level-select screen where you pick which
one to play — but **level 2 is locked until you finish level 1**.

## Refrigerator friends

Scattered around the levels are **10 refrigerator friends** to find. When you
find one, you can play as them.

Each friend has their own **unique hat**:

| Friend | Hat |
|---|---|
| Watermelon | Sunglasses |
| Strawberry | A hat made out of leaves |
| Blueberry | A backwards blue hat |
| Coconut | A coconut head with a straw in it |
| Macaroon | A hat that says "SWEET TREAT" on it |
| Ice Cream | An ice cream cone hat |
| Popsicle | A popsicle stick hat |
| *(open)* | ? |
| *(open)* | ? |
| *(open)* | ? |

That's 7 so far — 3 more to invent. Earlier ideas that could fill the gaps:
**Grape** and **Mac and Cheese Bowl**.

## Build order

We build one piece at a time. Each piece has to actually work before we start
the next one.

- [x] 1. A fridge shelf, and Milky standing on it
- [x] 2. Milky runs and jumps (arrow keys + space)
- [x] 3. Milky looks like a blue milk carton with googly eyes
- [x] 3b. Camera follows Milky around
- [x] 4. Platforms made of fridge stuff — butter, cereal box, soda can,
      egg carton, pizza box, jam jar, cheese block
- [x] 5. Four friends hidden in the level you can walk into and pick up
      (watermelon, macaroon, ice cream, popsicle) + a "Friends found" counter
- [x] 6. **The Food Locker** — press L to open it and switch between any
      friend you've found. Finding a friend puts them in the locker.
- [x] 7. Hands, feet, faces and shading on everybody — limbs swing when you
      walk, tuck up when you jump, and you turn to face the way you go
- [x] 8. Fridge platforms decorated (cereal label, soda tab, egg bumps,
      pizza vents, cheese holes, jam jar lid)
- [ ] 9. The other 6 friends
- [x] 10. Hats! Watermelon has sunglasses, Macaroon has the SWEET TREAT cap,
      Ice Cream has a cone hat, Popsicle has a stick hat. Each hat is its own
      scene in `scenes/hats/` so a friend can swap hats later.
- [x] 10b. Hats are their OWN thing now — the locker has FOODS and HATS tabs,
      and any hat goes on any character (Milky in sunglasses!). Each look has
      a HeadMount and a FaceMount so hats land in the right spot.
- [ ] 10c. Hats for the friends not built yet — strawberry (leaf hat),
      blueberry (backwards blue cap), coconut (coconut + straw)
- [x] 10d. **Redo button** — press R to go back to the start. You keep every
      friend and hat. If you fall off the world it catches you automatically.
- [x] 10e. **Milky's Stall** at the end of the level — striped awning, sign,
      and a counter you can stand on.
- [x] 10f. **"YOU GOT ___!" pop-up** when you find a friend, using their
      nickname: MELON, LOON, CREAM, POP.
- [x] 11. **Gold star** at the end of each level. Touch it and a LEVEL
      COMPLETE panel appears with NEXT LEVEL / KEEP EXPLORING THIS ONE.
- [x] 12. **Level 2 exists** — the fridge door. Yogurt cup, ketchup, pickle
      jar, milk jug, mustard, orange juice, butter tub. Has its own star, but
      nothing after it yet, so its button says MORE COMING SOON.
- [ ] 13. Friends to find in Level 2 (it's empty of friends right now)
- [ ] 14. The level-select screen with the lock on Level 2

## How to add a new friend (it's 3 steps now)

1. Copy one of the `scenes/looks/look_*.tscn` files and change the shapes.
2. Add one line to the `LOOKS` list in `scripts/locker.gd`.
3. Copy one of the `scenes/friend_*.tscn` files, point it at the new look,
   and change `friend_name`.

Then drop it in the level. The counter and the locker update themselves.
