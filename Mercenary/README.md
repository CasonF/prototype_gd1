# Mercenary
Repo for Godot game project: Mercenary
Sections will be added and modified as needed as the project progresses.


### ~~Adding new weapons~~ This section needs to be updated
To create a new weapon asset, first create a new 2D Node.
Name the base node the name of the weapon in camelCase (for consistency).

After creating this node, attach a Sprite2D node to it as a child to the parent node (see below).

![image](https://github.com/CasonF/mercenary/assets/75468526/04fca62f-ee3d-425f-b51f-14910f994bb4)

You can assign an image to the Sprite2D node now, if you'd like, but it is not required for this next part.

Next, you will attach the Weapon.gd script to the parent node.
When you attach the script to the node, a dropdown should appear in the top right of the inspector that says "Weapon Res" (short for Weapon Resource).
Select the dropdown -> Select "New Weapon Template"

You should now see several empty fields that need to be filled in. Currently, the following fields are supported:
- Type (enum-string)
- Name (string)
- Range (int)
- Base Damage (int)
- Element (enum-string)
- Critical Hit Chance (float)
- Critical Damage Multiplier (float)
- Max Durability (int)

Below is an example of the fields filled out for an "Iron Sword"

![image](https://github.com/CasonF/mercenary/assets/75468526/63c6f0b4-02b3-4695-8070-32efec43930d)
