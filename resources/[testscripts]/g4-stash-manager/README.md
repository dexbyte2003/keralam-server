# G4 Stash Manager

A FiveM script for dynamically creating and managing stashes and shops using `ox_lib` and `ox_inventory`.

## Features
- **In-game Stash Creation**: Create stashes at your current location with custom ID, label, slots, and weight.
- **In-game Shop Creation**: Create shops at your current location.
- **Dynamic Shop Editing**: Add items, set prices, and remove items from shops directly within the game.
- **Persistence**: All data is saved in your MySQL database.
- **Interaction**: Uses `ox_lib` points for markers and TextUI prompts.

## Requirements
- `ox_lib`
- `ox_inventory`
- `oxmysql`

## Usage
1. Ensure the script is started after `oxmysql`, `ox_lib`, and `ox_inventory`.
2. Use the command `/manageinventory` to open the creator menu.
3. Stand where you want the stash/shop to be and follow the prompts.
4. To edit a shop's items, open the manager and select "Manage Existing Shops".

## Installation
1. Copy the `g4-stash-manager` folder to your resources.
2. Add `ensure g4-stash-manager` to your `server.cfg`.
3. The database tables will be automatically created on the first start.

## Permissions
By default, the `/manageinventory` command is open to everyone. You should wrap the command in your framework's permission check (e.g., Qbox, QBCore, ESX).

Example for Qbox/QBCore:
```lua
RegisterCommand('manageinventory', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if player.PlayerData.permission == 'admin' then
        TriggerClientEvent('g4-stash-manager:client:openManager', source)
    end
end)
```
*(Note: You would need to change the RegisterCommand to server-side and trigger a client event if you want strict server-side permission checks)*
