if not (string.lower(Config["Framework"]) == "qb") then
  return Debug("Prevented the `qb.lua` file from continuing.")
end

local frameworkOptions = Config["Framework Options"]
QBState = {
  harnessHealth = 0
}
Script.framework.object = exports['qb-core']:GetCoreObject()
local QBCore = exports['qb-core']:GetCoreObject()

if frameworkOptions["Multi Character"] then
  Debug("(QB) Multi Character is enabled, initiating logic.")
  RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ToggleNuiFrame(true)
    Debug("(QB) Player Loaded and HUD is being displayed.")
  end)

  RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    ToggleNuiFrame(false)
    Debug("(QB) Player Unloaded and HUD is not being displayed.")
  end)
end

if frameworkOptions["Seatbelt"] then
  RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    Script.state.isSeatbeltOn = not Script.state.isSeatbeltOn
  end)
  Debug("(QB) SeatbeltState updated: ", Script.state.isSeatbeltOn)
end

if frameworkOptions["Status"] or frameworkOptions["Harness"] then
  Debug("(QB) Status is enabled, continuing logic.")
  Script.framework.init = function()
    CreateThread(function()
      while Script.visible do
        local playerData = QBCore.Functions.GetPlayerData()

        if not playerData or not playerData.metadata then
          return Debug("(QB) Error occured while attempting to get the playerData, debug: ", json.encode(playerData))
        end

        if frameworkOptions["Harness"] then
          HasHarness = exports['qb-smallresources']:HasHarness()
          Debug("(QB) Harness State: ", HasHarness)
        end

        local metadata = playerData.metadata


        local status = {
          hunger = math.floor(metadata["hunger"]),
          thirst = math.floor(metadata['thirst']),
          stress = math.floor(metadata["stress"]),
          harnessDurability = HasHarness and 100 or 0
        }

        UIMessage("nui:data:frameworkStatus", status)
        Wait(3000)
      end
    end)
  end

  xpcall(Script.framework.init, function(err)
    return print("Error when calling the `Script.framework.init` function on the qb.lua file", err)
  end)
end
