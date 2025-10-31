(() => {
  var __defProp = Object.defineProperty;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __name = (target, value) => __defProp(target, "name", { value, configurable: true });
  var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);

  // node_modules/.pnpm/@communityox+ox_lib@3.30.7/node_modules/@communityox/ox_lib/client/resource/streaming/index.js
  function streamingRequest(request, hasLoaded, assetType, asset, timeout = 3e4, ...args) {
    if (hasLoaded(asset))
      return asset;
    request(asset, ...args);
    return waitFor(() => {
      if (hasLoaded(asset))
        return asset;
    }, `failed to load ${assetType} '${asset}' - this may be caused by
- too many loaded assets
- oversized, invalid, or corrupted assets`, timeout);
  }
  __name(streamingRequest, "streamingRequest");
  var requestAnimDict = /* @__PURE__ */ __name((animDict, timeout) => {
    if (!DoesAnimDictExist(animDict))
      throw new Error(`attempted to load invalid animDict '${animDict}'`);
    return streamingRequest(RequestAnimDict, HasAnimDictLoaded, "animDict", animDict, timeout);
  }, "requestAnimDict");
  var requestModel = /* @__PURE__ */ __name((model3, timeout) => {
    if (typeof model3 !== "number")
      model3 = GetHashKey(model3);
    if (!IsModelValid(model3))
      throw new Error(`attempted to load invalid model '${model3}'`);
    return streamingRequest(RequestModel, HasModelLoaded, "model", model3, timeout);
  }, "requestModel");
  var requestNamedPtfxAsset = /* @__PURE__ */ __name((ptFxName, timeout) => streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, "ptFxName", ptFxName, timeout), "requestNamedPtfxAsset");

  // node_modules/.pnpm/@communityox+ox_lib@3.30.7/node_modules/@communityox/ox_lib/shared/resource/cache/index.js
  var cacheEvents = {};
  var cache = new Proxy({
    resource: GetCurrentResourceName(),
    game: GetGameName()
  }, {
    get(target, key) {
      const result = key ? target[key] : target;
      if (result !== void 0)
        return result;
      cacheEvents[key] = [];
      AddEventHandler(`ox_lib:cache:${key}`, (value) => {
        const oldValue = target[key];
        const events = cacheEvents[key];
        events.forEach((cb) => cb(value, oldValue));
        target[key] = value;
      });
      target[key] = exports.ox_lib.cache(key) || false;
      return target[key];
    }
  });

  // node_modules/.pnpm/@communityox+ox_lib@3.30.7/node_modules/@communityox/ox_lib/shared/index.js
  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms, null));
  }
  __name(sleep, "sleep");
  async function waitFor(cb, errMessage, timeout) {
    let value = await cb();
    if (value !== void 0)
      return value;
    if (timeout || timeout == null) {
      if (typeof timeout !== "number")
        timeout = 1e3;
    }
    const start = GetGameTimer();
    let id;
    const p = new Promise((resolve, reject) => {
      id = setTick(async () => {
        const elapsed = timeout && GetGameTimer() - start;
        if (elapsed && elapsed > timeout) {
          return reject(`${errMessage || "failed to resolve callback"} (waited ${elapsed}ms)`);
        }
        value = await cb();
        if (value !== void 0)
          resolve(value);
      });
    }).finally(() => clearTick(id));
    return p;
  }
  __name(waitFor, "waitFor");

  // src/client/classes/player/Player.ts
  var _ClientPlayerC = class _ClientPlayerC {
    constructor() {
      __publicField(this, "activeTrolls", []);
    }
    trollIsActive(troll) {
      return this.activeTrolls.includes(troll);
    }
    async playTroll(trollClass) {
      if (this.trollIsActive(trollClass.trollName)) return;
      this.activeTrolls.push(trollClass.trollName);
      const needStop = await trollClass.start();
      if (needStop) this.stopTroll(trollClass);
    }
    stopTroll(trollClass) {
      if (!this.trollIsActive(trollClass.trollName)) return;
      trollClass.stop();
      this.activeTrolls = this.activeTrolls.filter(
        (t) => t !== trollClass.trollName
      );
    }
  };
  __name(_ClientPlayerC, "ClientPlayerC");
  var ClientPlayerC = _ClientPlayerC;
  var Player_default = ClientPlayerC;

  // src/common/resource.ts
  var IsBrowser = typeof window === "undefined" ? 0 : typeof window.GetParentResourceName !== "undefined" ? 1 : 2;
  var ResourceContext = IsBrowser ? "web" : IsDuplicityVersion() ? "server" : "client";
  var ResourceName = IsBrowser ? IsBrowser === 1 ? window.GetParentResourceName() : "nui-frame-app" : GetCurrentResourceName();

  // src/common/config.ts
  var config = LoadJsonFile("static/config.json");
  var config_default = config;

  // src/common/utils.ts
  function LoadFile(path) {
    return LoadResourceFile(ResourceName, path);
  }
  __name(LoadFile, "LoadFile");
  function LoadJsonFile(path) {
    if (!IsBrowser) return JSON.parse(LoadFile(path));
    const resp = fetch(`/${path}`, {
      method: "post",
      headers: {
        "Content-Type": "application/json; charset=UTF-8"
      }
    });
    return resp.then((response) => response.json());
  }
  __name(LoadJsonFile, "LoadJsonFile");
  function debugPrint(message) {
    if (!config_default.debugEnable) return;
    console.log(message);
  }
  __name(debugPrint, "debugPrint");
  function sendNuiMessage(action, data) {
    SendNUIMessage({ action, data: data || {} });
  }
  __name(sendNuiMessage, "sendNuiMessage");

  // src/client/classes/troll/index.ts
  var _MainTroll = class _MainTroll {
    constructor(name) {
      __publicField(this, "trollName");
      this.trollName = name;
    }
    stop() {
      emitNet(`${cache.resource}:trolStopped`, this.trollName);
    }
  };
  __name(_MainTroll, "MainTroll");
  var MainTroll = _MainTroll;
  var troll_default = MainTroll;

  // src/client/utils/playSound.ts
  var activeSounds = /* @__PURE__ */ new Map();
  async function requestScriptAudioBank() {
    let currentTimer = GetGameTimer();
    const isTimeout = /* @__PURE__ */ __name(() => GetGameTimer() - currentTimer >= 2e3, "isTimeout");
    while (!RequestScriptAudioBank("tgiannadmintroll/sounds", false) && !isTimeout())
      await sleep(100);
    return !isTimeout();
  }
  __name(requestScriptAudioBank, "requestScriptAudioBank");
  async function playSound(soundFile, entity = cache.ped) {
    const loaded = await requestScriptAudioBank();
    if (!loaded)
      console.error("Failed to load audio bank: tgiannadmintroll/sounds!");
    const soundId = GetSoundId();
    debugPrint(
      `Playing sound ${soundFile} with soundId ${soundId} on entity ${entity} | My Ped: ${cache.ped}`
    );
    PlaySoundFromEntity(
      soundId,
      soundFile,
      entity,
      "tgiann_admin_troll",
      false,
      0
    );
    ReleaseNamedScriptAudioBank("tgiannadmintroll/sounds");
    return soundId;
  }
  __name(playSound, "playSound");
  async function playSoundFrontend(soundFile) {
    await requestScriptAudioBank();
    const soundId = GetSoundId();
    debugPrint(`Playing sound ${soundFile} with soundId ${soundId} on frontend`);
    PlaySoundFrontend(soundId, soundFile, "tgiann_admin_troll", false);
    ReleaseNamedScriptAudioBank("tgiannadmintroll/sounds");
    return soundId;
  }
  __name(playSoundFrontend, "playSoundFrontend");
  function stopSound(soundId) {
    StopSound(soundId);
    ReleaseSoundId(soundId);
    debugPrint(`Stopped sound with soundId ${soundId}`);
  }
  __name(stopSound, "stopSound");
  async function playNetworkSound(soundFile) {
    emitNet(`${cache.resource}:playSound`, soundFile);
    let soundId = void 0;
    while (soundId === void 0) {
      soundId = activeSounds.get(cache.serverId);
      await sleep(100);
    }
    return soundId;
  }
  __name(playNetworkSound, "playNetworkSound");
  function stopNetworkSound() {
    debugPrint("Stopping network sound");
    emitNet(`${cache.resource}:stopSound`);
  }
  __name(stopNetworkSound, "stopNetworkSound");
  AddStateBagChangeHandler(
    "tgiann_troll_sound",
    null,
    async (bagName, key, value) => {
      const ply = GetPlayerFromStateBagName(bagName);
      if (ply === 0) return;
      const ped = GetPlayerPed(ply);
      const serverId = GetPlayerServerId(ply);
      debugPrint(
        `tgiann_troll_sound state bag changed: ${value} for ${serverId}`
      );
      if (value) {
        const soundId = await playSound(value, ped);
        activeSounds.set(serverId, soundId);
      } else {
        const soundId = activeSounds.get(serverId);
        if (soundId !== void 0) {
          stopSound(soundId);
          activeSounds.delete(serverId);
        }
      }
    }
  );

  // src/client/classes/troll/FartOne.ts
  var _FartOne = class _FartOne extends troll_default {
    async start() {
      const soundId = await playNetworkSound("fart1");
      while (!HasSoundFinished(soundId)) await sleep(100);
      stopNetworkSound();
      return true;
    }
  };
  __name(_FartOne, "FartOne");
  var FartOne = _FartOne;
  var FartOne_default = new FartOne("fart_type_1");

  // src/client/classes/troll/FartTwo.ts
  var _FartTwo = class _FartTwo extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "soundId");
    }
    async start() {
      this.soundId = await playNetworkSound("fart2");
      while (this.soundId !== null && !HasSoundFinished(this.soundId))
        await sleep(100);
      if (this.soundId === null) return false;
      return true;
    }
    stop() {
      stopNetworkSound();
      this.soundId = null;
      super.stop();
    }
  };
  __name(_FartTwo, "FartTwo");
  var FartTwo = _FartTwo;
  var FartTwo_default = new FartTwo("fart_type_2");

  // src/client/utils/keyboardControl.ts
  function keyAction(key, action) {
    if (IsRawKeyPressed(key)) {
      action("pressed");
    } else if (IsRawKeyReleased(key)) {
      action("released");
    }
    if (IsRawKeyDown(key)) action("pressing");
  }
  __name(keyAction, "keyAction");
  function forceKeyboardControl(key) {
    if (key === "w") {
      SetControlNormal(0, 71, 1);
    } else if (key === "s") {
      SetControlNormal(0, 31, 1);
      SetControlNormal(0, 72, 1);
    } else if (key === "a") {
      SetControlNormal(0, 133, 1);
      SetControlNormal(0, 89, 1);
      SetControlNormal(0, 63, 1);
    } else if (key === "d") {
      SetControlNormal(0, 30, 1);
      SetControlNormal(0, 59, 1);
    } else if (key === "space") {
      if (cache.vehicle) {
        SetControlNormal(0, 76, 1);
      } else {
        if (!IsPedJumping(cache.ped)) TaskJump(cache.ped, false);
      }
    }
  }
  __name(forceKeyboardControl, "forceKeyboardControl");
  function disabeAllControls() {
    DisablePlayerFiring(cache.ped, true);
    DisableAllControlActions(0);
    EnableControlAction(0, 1, true);
    EnableControlAction(0, 2, true);
  }
  __name(disabeAllControls, "disabeAllControls");

  // src/client/classes/troll/ReverseControl.ts
  var _ReverseControl = class _ReverseControl extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "tick", null);
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      this.clearTick();
      this.tick = setTick(() => {
        keyAction(87, (action) => {
          if (action === "pressing") {
            DisableControlAction(0, 32, true);
            forceKeyboardControl("s");
          }
        });
        keyAction(83, (action) => {
          if (action === "pressing") {
            DisableControlAction(0, 31, true);
            DisableControlAction(0, 33, true);
            forceKeyboardControl("w");
          }
        });
        keyAction(65, (action) => {
          if (action === "pressing") {
            DisableControlAction(0, 34, true);
            forceKeyboardControl("d");
          }
        });
        keyAction(68, (action) => {
          if (action === "pressing") {
            DisableControlAction(0, 30, true);
            DisableControlAction(0, 35, true);
            forceKeyboardControl("a");
          }
        });
      });
      return false;
    }
    stop() {
      this.clearTick();
      super.stop();
    }
  };
  __name(_ReverseControl, "ReverseControl");
  var ReverseControl = _ReverseControl;
  var ReverseControl_default = new ReverseControl("reverse_control");

  // src/client/classes/troll/FakeLag.ts
  var _FakeLag = class _FakeLag extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "timeout", null);
    }
    clearTimeout() {
      if (this.timeout !== null) {
        clearTimeout(this.timeout);
        this.timeout = null;
      }
    }
    async fakeLag() {
      const currentCoords = GetEntityCoords(cache.ped, false);
      const forwardVector = GetEntityForwardVector(cache.ped);
      const newX = currentCoords[0] + forwardVector[0] * 3.5;
      const newY = currentCoords[1] + forwardVector[1] * 3.5;
      if (cache.vehicle) {
        SetEntityCoordsNoOffset(
          cache.vehicle,
          newX,
          newY,
          currentCoords[2],
          false,
          false,
          false
        );
        sleep(500);
        SetEntityCoordsNoOffset(
          cache.vehicle,
          currentCoords[0],
          currentCoords[1],
          currentCoords[2] - 1,
          false,
          false,
          false
        );
      } else {
        SetEntityCoords(
          cache.ped,
          newX,
          newY,
          currentCoords[2],
          false,
          false,
          false,
          true
        );
        await sleep(500);
        SetEntityCoords(
          cache.ped,
          currentCoords[0],
          currentCoords[1],
          currentCoords[2] - 1,
          false,
          false,
          false,
          true
        );
      }
      this.timeout = setTimeout(() => {
        this.fakeLag();
      }, 15e3);
    }
    async start() {
      this.clearTimeout();
      this.fakeLag();
      return false;
    }
    stop() {
      this.clearTimeout();
      super.stop();
    }
  };
  __name(_FakeLag, "FakeLag");
  var FakeLag = _FakeLag;
  var FakeLag_default = new FakeLag("fake_lag");

  // src/client/classes/troll/RandomTimeCycle.ts
  var _RandomTimeCycle = class _RandomTimeCycle extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "currentTime", [12, 0, 0]);
      __publicField(this, "timeout", null);
    }
    clearTimeout() {
      if (this.timeout !== null) {
        clearTimeout(this.timeout);
        this.timeout = null;
      }
    }
    async setRandomTime() {
      const hour = Math.floor(Math.random() * 24);
      const minute = Math.floor(Math.random() * 60);
      const second = Math.floor(Math.random() * 60);
      NetworkOverrideClockTime(hour, minute, second);
      this.timeout = setTimeout(() => {
        this.setRandomTime();
      }, Math.floor(Math.random() * 2e3) + 500);
    }
    async start() {
      this.currentTime = [GetClockHours(), GetClockMinutes(), GetClockSeconds()];
      this.clearTimeout();
      this.setRandomTime();
      return false;
    }
    stop() {
      NetworkOverrideClockTime(
        this.currentTime[0],
        this.currentTime[1],
        this.currentTime[2]
      );
      this.clearTimeout();
      super.stop();
    }
  };
  __name(_RandomTimeCycle, "RandomTimeCycle");
  var RandomTimeCycle = _RandomTimeCycle;
  var RandomTimeCycle_default = new RandomTimeCycle("random_time_cycle");

  // src/client/classes/troll/UltraSlowWalk.ts
  var _UltraSlowWalk = class _UltraSlowWalk extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "tick", null);
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      this.clearTick();
      this.tick = setTick(() => {
        SetPedMoveRateOverride(cache.ped, 0.1);
      });
      return false;
    }
    stop() {
      this.clearTick();
      super.stop();
    }
  };
  __name(_UltraSlowWalk, "UltraSlowWalk");
  var UltraSlowWalk = _UltraSlowWalk;
  var UltraSlowWalk_default = new UltraSlowWalk("ultra_slow_walk");

  // src/client/utils/entity.ts
  function getClosestVehicle(radius, coords) {
    const gamePool = GetGamePool("CVehicle");
    let closestVehicle = null;
    let closestDistance = radius;
    const checkCoords = coords || GetEntityCoords(cache.ped, false);
    for (const vehicle of gamePool) {
      const vehicleCoords = GetEntityCoords(vehicle, false);
      const distance = GetDistanceBetweenCoords(
        checkCoords[0],
        checkCoords[1],
        checkCoords[2],
        vehicleCoords[0],
        vehicleCoords[1],
        vehicleCoords[2],
        true
      );
      if (distance < closestDistance) {
        closestDistance = distance;
        closestVehicle = vehicle;
      }
    }
    return closestVehicle;
  }
  __name(getClosestVehicle, "getClosestVehicle");
  function deleteEntity(entity) {
    if (!DoesEntityExist(entity)) return;
    if (NetworkGetEntityIsNetworked(entity)) {
      const netId = NetworkGetNetworkIdFromEntity(entity);
      if (NetworkHasControlOfNetworkId(netId)) {
        emitNet(`${cache.resource}:deleteEntity`, netId);
      }
    }
    SetEntityAsMissionEntity(entity, true, true);
    DeleteEntity(entity);
  }
  __name(deleteEntity, "deleteEntity");
  async function createPed(model3, coords, isNetwork) {
    model3 = typeof model3 === "string" ? GetHashKey(model3) : model3;
    await requestModel(model3);
    const ped = CreatePed(
      4,
      model3,
      coords[0],
      coords[1],
      coords[2],
      0,
      isNetwork,
      false
    );
    SetPedCanRagdoll(ped, false);
    SetBlockingOfNonTemporaryEvents(ped, true);
    if (isNetwork) {
      const netId = NetworkGetNetworkIdFromEntity(ped);
      emitNet(`${cache.resource}:entitySpawned`, netId);
    }
    return ped;
  }
  __name(createPed, "createPed");
  async function createVehicle(model3, coords, isNetwork) {
    model3 = typeof model3 === "string" ? GetHashKey(model3) : model3;
    await requestModel(model3);
    const veh = CreateVehicle(
      model3,
      coords[0],
      coords[1],
      coords[2],
      0,
      isNetwork,
      false
    );
    SetVehicleOnGroundProperly(veh);
    SetEntityAsMissionEntity(veh, true, true);
    if (isNetwork) {
      const netId = NetworkGetNetworkIdFromEntity(veh);
      emitNet(`${cache.resource}:entitySpawned`, netId);
    }
    return veh;
  }
  __name(createVehicle, "createVehicle");
  function getEntityBackward(entity, distance = 1.5) {
    const entityPos = GetEntityCoords(entity, true);
    const forwardVector = GetEntityForwardVector(entity);
    const behindPos = [
      entityPos[0] - forwardVector[0] * distance,
      entityPos[1] - forwardVector[1] * distance,
      entityPos[2] - 1
    ];
    return behindPos;
  }
  __name(getEntityBackward, "getEntityBackward");
  function getEntityForward(entity, distance = 1.5) {
    const entityPos = GetEntityCoords(entity, true);
    const forwardVector = GetEntityForwardVector(entity);
    const inFrontPos = [
      entityPos[0] + forwardVector[0] * distance,
      entityPos[1] + forwardVector[1] * distance,
      entityPos[2] - 1
    ];
    return inFrontPos;
  }
  __name(getEntityForward, "getEntityForward");
  async function createObject(model3, coords, isNetwork) {
    model3 = typeof model3 === "string" ? GetHashKey(model3) : model3;
    await requestModel(model3);
    const object = CreateObject(
      model3,
      coords[0],
      coords[1],
      coords[2],
      isNetwork,
      false,
      false
    );
    SetEntityAsMissionEntity(object, true, true);
    if (isNetwork) {
      const netId = NetworkGetNetworkIdFromEntity(object);
      emitNet(`${cache.resource}:entitySpawned`, netId);
    }
    return object;
  }
  __name(createObject, "createObject");

  // src/client/classes/troll/VehicleDoorOpenClose.ts
  var _VehicleDoorOpenClose = class _VehicleDoorOpenClose extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "timeout", null);
    }
    clearTimeout() {
      if (this.timeout !== null) {
        clearTimeout(this.timeout);
        this.timeout = null;
      }
    }
    async closestVehicleDoorControl() {
      let vehicle = null;
      if (cache.vehicle) {
        vehicle = cache.vehicle;
      } else {
        vehicle = getClosestVehicle(15);
      }
      if (vehicle) {
        const doorCount = GetNumberOfVehicleDoors(vehicle);
        const doorIndex = Math.floor(Math.random() * doorCount);
        const isDoorOpen = GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0;
        if (isDoorOpen) {
          SetVehicleDoorShut(vehicle, doorIndex, false);
        } else {
          SetVehicleDoorOpen(vehicle, doorIndex, false, false);
        }
      }
      this.timeout = setTimeout(() => {
        this.closestVehicleDoorControl();
      }, Math.floor(Math.random() * 1e3) + 500);
    }
    async start() {
      this.clearTimeout();
      this.closestVehicleDoorControl();
      return false;
    }
    stop() {
      this.clearTimeout();
      super.stop();
    }
  };
  __name(_VehicleDoorOpenClose, "VehicleDoorOpenClose");
  var VehicleDoorOpenClose = _VehicleDoorOpenClose;
  var VehicleDoorOpenClose_default = new VehicleDoorOpenClose("door_open_close");

  // src/client/classes/troll/NukeSound.ts
  var _NukeSound = class _NukeSound extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "soundId");
    }
    async start() {
      this.soundId = await playSoundFrontend("siren");
      while (!HasSoundFinished(this.soundId)) await sleep(100);
      if (this.soundId === null) return false;
      stopSound(this.soundId);
      return true;
    }
    stop() {
      stopSound(this.soundId);
      this.soundId = null;
      super.stop();
    }
  };
  __name(_NukeSound, "NukeSound");
  var NukeSound = _NukeSound;
  var NukeSound_default = new NukeSound("nuke_alert_sound");

  // src/client/classes/troll/FlipVehicle.ts
  var directions = ["left", "right"];
  var dirToVector = {
    left: [2, 0, 0],
    right: [-2, 0, 0]
    // forward: [0, -2, 0],
    // back: [0, 2, 0],
  };
  var _FlipVehicle = class _FlipVehicle extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "getDrivingVehicle", /* @__PURE__ */ __name(() => {
        return cache.vehicle && cache.seat === -1 ? cache.vehicle : null;
      }, "getDrivingVehicle"));
    }
    async start() {
      const vehicle = this.getDrivingVehicle();
      if (!vehicle) return true;
      const randomDir = directions[Math.floor(Math.random() * directions.length)];
      const randomDirVector = dirToVector[randomDir];
      const force = 10;
      ApplyForceToEntity(
        vehicle,
        1,
        0,
        0,
        force,
        randomDirVector[0],
        randomDirVector[1],
        randomDirVector[2],
        0,
        true,
        true,
        true,
        false,
        true
      );
      await sleep(2e3);
      return true;
    }
  };
  __name(_FlipVehicle, "FlipVehicle");
  var FlipVehicle = _FlipVehicle;
  var FlipVehicle_default = new FlipVehicle("flip_vehicle");

  // src/client/classes/troll/FlamePlayer.ts
  var _FlamePlayer = class _FlamePlayer extends troll_default {
    async start() {
      StartEntityFire(cache.ped);
      return false;
    }
    stop() {
      StopEntityFire(cache.ped);
      super.stop();
    }
  };
  __name(_FlamePlayer, "FlamePlayer");
  var FlamePlayer = _FlamePlayer;
  var FlamePlayer_default = new FlamePlayer("flame");

  // src/client/classes/troll/TwoDGame.ts
  var CAMERA_OFFSET_MAX = 20;
  var clamp = /* @__PURE__ */ __name((value, min, max) => Math.max(min, Math.min(max, value)), "clamp");
  var lerp = /* @__PURE__ */ __name((a, b, t) => a + (b - a) * t, "lerp");
  var _TwoDGame = class _TwoDGame extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "camera");
      __publicField(this, "tick");
      __publicField(this, "lastPos");
      __publicField(this, "cameraOffset");
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      this.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
      SetCamAffectsAiming(this.camera, false);
      this.lastPos = GetEntityCoords(cache.ped, false);
      this.cameraOffset = [0, 0, 0];
      this.tick = setTick(() => {
        const pos = GetEntityCoords(cache.ped, false);
        const targetCameraOffset = [
          clamp(
            lerp(
              -CAMERA_OFFSET_MAX,
              CAMERA_OFFSET_MAX,
              0.5 + (pos[0] - this.lastPos[0]) / 3
            ),
            -CAMERA_OFFSET_MAX,
            CAMERA_OFFSET_MAX
          ),
          clamp(
            lerp(
              -CAMERA_OFFSET_MAX,
              CAMERA_OFFSET_MAX,
              0.5 + (pos[1] - this.lastPos[1]) / 3
            ),
            -CAMERA_OFFSET_MAX,
            CAMERA_OFFSET_MAX
          ),
          0
        ];
        this.lastPos = pos;
        this.cameraOffset = [
          lerp(
            this.cameraOffset[0],
            targetCameraOffset[0],
            clamp(
              Math.abs(targetCameraOffset[0] - this.cameraOffset[0]) * 0.2,
              0,
              1
            )
          ),
          lerp(
            this.cameraOffset[1],
            targetCameraOffset[1],
            clamp(
              Math.abs(targetCameraOffset[1] - this.cameraOffset[1]) * 0.2,
              0,
              1
            )
          ),
          0
        ];
        SetCamFov(this.camera, 70);
        SetCamCoord(
          this.camera,
          pos[0] + this.cameraOffset[0],
          pos[1] + this.cameraOffset[1],
          pos[2] + 20
        );
        SetCamRot(this.camera, -90, 0, GetEntityHeading(cache.ped), 0);
        RenderScriptCams(true, true, 500, false, false);
      });
      return false;
    }
    stop() {
      this.clearTick();
      RenderScriptCams(false, true, 500, false, false);
      DestroyCam(this.camera, true);
      super.stop();
    }
  };
  __name(_TwoDGame, "TwoDGame");
  var TwoDGame = _TwoDGame;
  var TwoDGame_default = new TwoDGame("2d_game");

  // src/client/classes/troll/FlipCamera.ts
  var _FartTwo2 = class _FartTwo2 extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "flippedCamera");
      __publicField(this, "tick");
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      this.flippedCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
      RenderScriptCams(true, true, 700, true, true);
      this.tick = setTick(() => {
        const coord = GetGameplayCamCoord();
        const rot = GetGameplayCamRot(2);
        const fov = GetGameplayCamFov();
        SetCamParams(
          this.flippedCamera,
          coord[0],
          coord[1],
          coord[2],
          rot[0],
          180,
          rot[2],
          fov,
          700,
          0,
          0,
          2
        );
      });
      return false;
    }
    stop() {
      this.clearTick();
      RenderScriptCams(false, true, 700, true, true);
      DestroyCam(this.flippedCamera, true);
      super.stop();
    }
  };
  __name(_FartTwo2, "FartTwo");
  var FartTwo2 = _FartTwo2;
  var FlipCamera_default = new FartTwo2("flip_camera");

  // src/client/classes/troll/CloneFollow.ts
  var _CloneFollow = class _CloneFollow extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "ped", null);
      __publicField(this, "tick", null);
      __publicField(this, "clearTick", /* @__PURE__ */ __name(() => {
        if (this.tick) {
          clearTick(this.tick);
          this.tick = null;
        }
      }, "clearTick"));
      __publicField(this, "deletePed", /* @__PURE__ */ __name(() => {
        if (this.ped) {
          deleteEntity(this.ped);
          this.ped = null;
        }
      }, "deletePed"));
      __publicField(this, "getPlayerBehindPos", /* @__PURE__ */ __name(() => {
        const behindPos = getEntityBackward(cache.ped);
        return behindPos;
      }, "getPlayerBehindPos"));
    }
    async start() {
      this.ped = ClonePed(cache.ped, false, false, true);
      const behindPos = this.getPlayerBehindPos();
      SetEntityCoords(
        this.ped,
        behindPos[0],
        behindPos[1],
        behindPos[2],
        false,
        false,
        false,
        false
      );
      SetEntityInvincible(this.ped, true);
      SetPedCanRagdoll(this.ped, false);
      SetBlockingOfNonTemporaryEvents(this.ped, true);
      this.tick = setTick(() => {
        if (!DoesEntityExist(this.ped)) return;
        const behindPos2 = this.getPlayerBehindPos();
        TaskGoStraightToCoord(
          this.ped,
          behindPos2[0],
          behindPos2[1],
          behindPos2[2],
          6,
          0.1,
          GetEntityHeading(cache.ped),
          0.5
        );
      });
      return false;
    }
    stop() {
      this.clearTick();
      this.deletePed();
      super.stop();
    }
  };
  __name(_CloneFollow, "CloneFollow");
  var CloneFollow = _CloneFollow;
  var CloneFollow_default = new CloneFollow("clone_follow");

  // src/client/utils/aggressiveNpc.ts
  async function createAggressiveNpc(model3, coords, weapon) {
    const ped = await createPed(model3, coords, true);
    SetEntityInvincible(ped, true);
    if (weapon) {
      const weaponHash = GetHashKey(weapon);
      GiveWeaponToPed(ped, weaponHash, 9999, false, true);
      SetCurrentPedWeapon(ped, weaponHash, true);
      SetPedInfiniteAmmo(ped, true, weaponHash);
    }
    TaskCombatPed(ped, cache.ped, 0, 16);
    return ped;
  }
  __name(createAggressiveNpc, "createAggressiveNpc");

  // src/client/utils/getPlayerArroundCoords.ts
  function getPlayerArroundCoords(radius = 5) {
    const playerCoords = GetEntityCoords(cache.ped, false);
    const newCoords = [
      playerCoords[0] + radius,
      playerCoords[1] + radius,
      playerCoords[2]
    ];
    const [retval, coords] = GetClosestVehicleNode(
      newCoords[0],
      newCoords[1],
      newCoords[2],
      1,
      10,
      10
    );
    if (retval) return coords;
    return newCoords;
  }
  __name(getPlayerArroundCoords, "getPlayerArroundCoords");

  // src/client/classes/troll/AttackNpc.ts
  var model = ["s_m_y_blackops_01", "s_m_y_marine_01", "s_m_y_swat_01"];
  var _AttackNpc = class _AttackNpc extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "ped", null);
      __publicField(this, "deletePed", /* @__PURE__ */ __name(() => {
        if (this.ped) {
          deleteEntity(this.ped);
          this.ped = null;
        }
      }, "deletePed"));
    }
    async start() {
      const randomModel = model[Math.floor(Math.random() * model.length)];
      const coords = getPlayerArroundCoords(30);
      this.ped = await createAggressiveNpc(randomModel, coords, "weapon_pistol");
      return false;
    }
    stop() {
      this.deletePed();
      super.stop();
    }
  };
  __name(_AttackNpc, "AttackNpc");
  var AttackNpc = _AttackNpc;
  var AttackNpc_default = new AttackNpc("attack_npc");

  // src/client/classes/troll/AttackAnimal.ts
  var model2 = ["a_c_chimp", "a_c_husky", "a_c_retriever", "a_c_shepherd"];
  var _AttackAnimal = class _AttackAnimal extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "ped", null);
      __publicField(this, "deletePed", /* @__PURE__ */ __name(() => {
        if (this.ped) {
          deleteEntity(this.ped);
          this.ped = null;
        }
      }, "deletePed"));
    }
    async start() {
      const randomModel = model2[Math.floor(Math.random() * model2.length)];
      const coords = getPlayerArroundCoords(20);
      this.ped = await createAggressiveNpc(randomModel, coords);
      return false;
    }
    stop() {
      this.deletePed();
      super.stop();
    }
  };
  __name(_AttackAnimal, "AttackAnimal");
  var AttackAnimal = _AttackAnimal;
  var AttackAnimal_default = new AttackAnimal("attack_animal");

  // src/client/classes/troll/FlipPlayer.ts
  var _FlipVehicle2 = class _FlipVehicle2 extends troll_default {
    async start() {
      SetPedToRagdoll(cache.ped, 200, 0, 0, true, true, false);
      ApplyForceToEntity(
        cache.ped,
        1,
        0,
        0,
        10,
        2,
        0,
        0,
        0,
        true,
        true,
        true,
        false,
        true
      );
      await sleep(2e3);
      return true;
    }
  };
  __name(_FlipVehicle2, "FlipVehicle");
  var FlipVehicle2 = _FlipVehicle2;
  var FlipPlayer_default = new FlipVehicle2("flip_player");

  // src/client/classes/troll/Kidnap.ts
  var _Kidnap = class _Kidnap extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "vehicle");
      __publicField(this, "disableControlTick");
      __publicField(this, "peds", {
        driver: null,
        ped1: null,
        ped2: null
      });
    }
    async CreatePed(coords, model3) {
      const ped = await createPed(model3, coords, true);
      SetEntityInvincible(ped, true);
      return ped;
    }
    async createVehicle(coords) {
      const veh = await createVehicle("burrito", coords, true);
      SetEntityInvincible(veh, true);
      return veh;
    }
    async playKidnapAnimation() {
      const targetPosition = GetEntityCoords(this.vehicle, true);
      const targetRotation = GetEntityRotation(this.vehicle, 2);
      const KidnapScene = NetworkCreateSynchronisedScene(
        targetPosition[0],
        targetPosition[1],
        targetPosition[2],
        targetRotation[0],
        targetRotation[1],
        targetRotation[2],
        2,
        false,
        false,
        1065353216,
        0,
        1
      );
      const AnimDic = "random@kidnap_girl";
      NetworkAddPedToSynchronisedScene(
        this.peds.ped1,
        KidnapScene,
        AnimDic,
        "ig_1_guy1_drag_into_van",
        1.5,
        -4,
        1,
        16,
        1148846080,
        0
      );
      NetworkAddPedToSynchronisedScene(
        this.peds.ped2,
        KidnapScene,
        AnimDic,
        "ig_1_guy2_drag_into_van",
        1.5,
        -4,
        1,
        16,
        1148846080,
        0
      );
      NetworkAddPedToSynchronisedScene(
        cache.ped,
        KidnapScene,
        AnimDic,
        "ig_1_girl_drag_into_van",
        1.5,
        -4,
        1,
        16,
        1148846080,
        0
      );
      NetworkAddEntityToSynchronisedScene(
        this.vehicle,
        KidnapScene,
        AnimDic,
        "drag_into_van_burr",
        1,
        1,
        1
      );
      NetworkStartSynchronisedScene(KidnapScene);
      await sleep(GetAnimDuration(AnimDic, "drag_into_van_burr") * 750);
      TaskWarpPedIntoVehicle(this.peds.ped1, this.vehicle, 0);
      TaskWarpPedIntoVehicle(this.peds.ped2, this.vehicle, 1);
      TaskWarpPedIntoVehicle(cache.ped, this.vehicle, 2);
    }
    async prapareVehicleAndPeds() {
      const spawnCoords = getPlayerArroundCoords(20);
      this.peds.driver = await this.CreatePed(spawnCoords, "s_m_y_dealer_01");
      this.peds.ped1 = await this.CreatePed(spawnCoords, "s_m_y_dealer_01");
      this.peds.ped2 = await this.CreatePed(spawnCoords, "s_m_y_dealer_01");
      this.vehicle = await this.createVehicle(spawnCoords);
      TaskWarpPedIntoVehicle(this.peds.driver, this.vehicle, -1);
      TaskWarpPedIntoVehicle(this.peds.ped1, this.vehicle, 0);
      TaskWarpPedIntoVehicle(this.peds.ped2, this.vehicle, 1);
    }
    async goToCoords(speed, coords) {
      const vehicleModel = GetEntityModel(this.vehicle);
      const startedTime = GetGameTimer();
      SetDriverAbility(this.peds.driver, 1);
      SetDriverAggressiveness(this.peds.driver, 0);
      while (true) {
        const vehicleCoords = GetEntityCoords(this.vehicle, true);
        const gotLocation = coords || GetEntityCoords(cache.ped, false);
        const distance = GetDistanceBetweenCoords(
          gotLocation[0],
          gotLocation[1],
          gotLocation[2],
          vehicleCoords[0],
          vehicleCoords[1],
          vehicleCoords[2],
          true
        );
        TaskVehicleDriveToCoord(
          this.peds.driver,
          this.vehicle,
          gotLocation[0],
          gotLocation[1],
          gotLocation[2],
          speed,
          0,
          vehicleModel,
          786475,
          1,
          1
        );
        if (distance < 9) {
          TaskVehicleTempAction(this.peds.driver, this.vehicle, 27, 6e3);
          break;
        }
        if (GetGameTimer() - startedTime > 3e4) {
          SetEntityCoords(
            this.vehicle,
            gotLocation[0],
            gotLocation[1],
            gotLocation[2] - 1,
            false,
            false,
            false,
            false
          );
          break;
        }
        await sleep(1e3);
      }
    }
    async goToPlayer() {
      await this.goToCoords(25);
    }
    async goToFinalPoint() {
      const finishCoords = getPlayerArroundCoords(150);
      await this.goToCoords(45, finishCoords);
    }
    async disabeAllControls() {
      this.disableControlTick = setTick(disabeAllControls);
    }
    async finishKidnap() {
      DoScreenFadeOut(500);
      await sleep(1e3);
      if (this.disableControlTick) {
        clearTick(this.disableControlTick);
        this.disableControlTick = null;
      }
      deleteEntity(this.vehicle);
      deleteEntity(this.peds.driver);
      deleteEntity(this.peds.ped1);
      deleteEntity(this.peds.ped2);
      SetEntityCoords(
        cache.ped,
        -1629.098877,
        -1058.479126,
        4.712769,
        false,
        false,
        false,
        false
      );
      SetPedToRagdoll(cache.ped, 1e4, 1e4, 0, false, false, false);
      await sleep(3e3);
      DoScreenFadeIn(500);
    }
    async start() {
      await this.prapareVehicleAndPeds();
      await this.goToPlayer();
      this.disabeAllControls();
      await this.playKidnapAnimation();
      await this.goToFinalPoint();
      await this.finishKidnap();
      return true;
    }
  };
  __name(_Kidnap, "Kidnap");
  var Kidnap = _Kidnap;
  var Kidnap_default = new Kidnap("kidnap");

  // src/client/classes/troll/Ghost.ts
  var ghostModels = [
    "m23_1_prop_m31_ghostsalton_01a",
    "m23_1_prop_m31_ghostskidrow_01a",
    "m23_1_prop_m31_ghostzombie_01a",
    "m23_1_prop_m31_ghostrurmeth_01a",
    "m23_1_prop_m31_ghostjohnny_01a"
  ];
  var _Ghost = class _Ghost extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "tick");
      __publicField(this, "object");
      __publicField(this, "particle");
      __publicField(this, "currentTime", [12, 0, 0]);
    }
    deleteParticle() {
      if (this.particle) {
        StopParticleFxLooped(this.particle, true);
        this.particle = null;
      }
    }
    deleteEntity() {
      deleteEntity(this.object);
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      let active = true;
      this.currentTime = [GetClockHours(), GetClockMinutes(), GetClockSeconds()];
      const randomModel = ghostModels[Math.floor(Math.random() * ghostModels.length)];
      const coords = getEntityForward(cache.ped, 10);
      this.object = await createObject(randomModel, coords, false);
      SetEntityHeading(this.object, GetEntityHeading(cache.ped));
      await requestAnimDict("ANIM@SCRIPTED@FREEMODE@IG2_GHOST@");
      PlayEntityAnim(
        this.object,
        "float_1",
        "ANIM@SCRIPTED@FREEMODE@IG2_GHOST@",
        1e3,
        true,
        true,
        true,
        0,
        136704
      );
      await requestNamedPtfxAsset("scr_srr_hal");
      UseParticleFxAsset("scr_srr_hal");
      this.particle = StartParticleFxLoopedOnEntity(
        "scr_srr_hal_ghost_haze",
        this.object,
        0,
        0,
        0.7,
        0,
        0,
        0,
        1,
        false,
        false,
        false
      );
      SetParticleFxLoopedEvolution(this.particle, "smoke", 10, true);
      RemoveNamedPtfxAsset("scr_srr_hal");
      this.clearTick();
      this.tick = setTick(() => {
        NetworkOverrideClockTime(0, 0, 0);
        const playerCoords = GetEntityCoords(cache.ped, false);
        const distance = GetDistanceBetweenCoords(
          playerCoords[0],
          playerCoords[1],
          playerCoords[2],
          coords[0],
          coords[1],
          coords[2],
          true
        );
        if (distance < 5 || distance > 20) active = false;
      });
      while (active) await sleep(250);
      return this.tick !== null;
    }
    stop() {
      this.clearTick();
      this.deleteEntity();
      this.deleteParticle();
      NetworkOverrideClockTime(
        this.currentTime[0],
        this.currentTime[1],
        this.currentTime[2]
      );
      super.stop();
    }
  };
  __name(_Ghost, "Ghost");
  var Ghost = _Ghost;
  var Ghost_default = new Ghost("ghost");

  // src/client/classes/troll/UfoKidnap.ts
  var _UfoKidnap = class _UfoKidnap extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "disableControlTick");
    }
    deleteEntity() {
      emitNet(`${cache.resource}:server:deleteUfo`);
    }
    async disabeAllControls() {
      this.disableControlTick = setTick(disabeAllControls);
    }
    async teleportPlayerToFinishWithEffect() {
      DoScreenFadeOut(500);
      await sleep(1e3);
      SetEntityCoords(
        cache.ped,
        -1171.714233,
        4926.791016,
        224.198486,
        false,
        false,
        false,
        false
      );
      SetPedToRagdoll(cache.ped, 1e4, 1e4, 0, false, false, false);
      await sleep(3e3);
      DoScreenFadeIn(500);
    }
    async teleportPlayerToUfo(maxHeight) {
      let speed = 1e-3;
      let currentHeight = GetEntityCoords(cache.ped, false)[2];
      while (currentHeight <= maxHeight) {
        const playerCoords = GetEntityCoords(cache.ped, false);
        currentHeight = playerCoords[2] - 1;
        SetEntityCoords(
          cache.ped,
          playerCoords[0],
          playerCoords[1],
          currentHeight + speed,
          false,
          false,
          false,
          false
        );
        speed += 25e-4;
        await sleep(10);
      }
    }
    async start() {
      FreezeEntityPosition(cache.ped, true);
      this.disabeAllControls();
      const ufoSpawnCoords = GetEntityCoords(cache.ped, false);
      emitNet(`${cache.resource}:server:spawnUfo`, [
        ufoSpawnCoords[0],
        ufoSpawnCoords[1],
        ufoSpawnCoords[2] - 1
      ]);
      await sleep(5e3);
      await this.teleportPlayerToUfo(ufoSpawnCoords[2] + 200);
      await this.teleportPlayerToFinishWithEffect();
      FreezeEntityPosition(cache.ped, false);
      clearTick(this.disableControlTick);
      this.deleteEntity();
      return true;
    }
  };
  __name(_UfoKidnap, "UfoKidnap");
  var UfoKidnap = _UfoKidnap;
  var UfoKidnap_default = new UfoKidnap("ufo_kidnap");

  // src/client/classes/troll/ForceControl.ts
  var _ForceControl = class _ForceControl extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "activeKeys", []);
      __publicField(this, "tickInterval", null);
    }
    async start() {
      onNet(
        `${cache.resource}:forceControlApply`,
        (key, action) => {
          if (action === "pressed") {
            if (!this.activeKeys.includes(key)) {
              this.activeKeys = [...this.activeKeys, key];
            }
          } else if (action === "released") {
            this.activeKeys = this.activeKeys.filter(
              (activeKey) => activeKey !== key
            );
          }
        }
      );
      this.tickInterval = setTick(() => {
        for (const key of this.activeKeys) {
          forceKeyboardControl(key);
        }
      });
      return false;
    }
    async stop() {
      if (this.tickInterval) {
        clearTick(this.tickInterval);
        this.tickInterval = null;
      }
      this.activeKeys = [];
      super.stop();
    }
  };
  __name(_ForceControl, "ForceControl");
  var ForceControl = _ForceControl;
  var ForceControl_default = new ForceControl("force_control_player");

  // src/client/classes/troll/LocalInvisiblity.ts
  var _localInvisibility = class _localInvisibility extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "timeout", null);
      __publicField(this, "tick", null);
      __publicField(this, "isInvisible", false);
    }
    destoryInvisibility() {
      this.isInvisible = false;
      SetEntityLocallyVisible(cache.ped);
      this.clearTimeout();
      this.clearTick();
      this.isInvisible = false;
    }
    clearTimeout() {
      if (this.timeout !== null) {
        clearTimeout(this.timeout);
        this.timeout = null;
      }
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async toggleInvisible() {
      this.timeout = setTimeout(() => {
        this.isInvisible = !this.isInvisible;
        this.toggleInvisible();
      }, Math.floor(Math.random() * 2500) + 1);
    }
    async start() {
      this.isInvisible = true;
      this.destoryInvisibility();
      this.toggleInvisible();
      this.tick = setTick(() => {
        if (this.isInvisible) SetEntityLocallyInvisible(cache.ped);
      });
      return false;
    }
    stop() {
      this.destoryInvisibility();
      super.stop();
    }
  };
  __name(_localInvisibility, "localInvisibility");
  var localInvisibility = _localInvisibility;
  var LocalInvisiblity_default = new localInvisibility("local_invisibility");

  // src/client/classes/troll/DisableLights.ts
  var _DisableLights = class _DisableLights extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "tick");
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      this.tick = setTick(() => {
        SetArtificialLightsState(true);
        SetArtificialLightsStateAffectsVehicles(false);
      });
      return false;
    }
    stop() {
      this.clearTick();
      SetArtificialLightsState(false);
      super.stop();
    }
  };
  __name(_DisableLights, "DisableLights");
  var DisableLights = _DisableLights;
  var DisableLights_default = new DisableLights("disable_lights");

  // src/client/classes/troll/ShrinkPlayer.ts
  var normalizeVector = /* @__PURE__ */ __name((vector, scale) => {
    const length = Math.sqrt(vector[0] ** 2 + vector[1] ** 2 + vector[2] ** 2);
    if (length === 0) return { x: 0, y: 0, z: 0 };
    return {
      x: vector[0] / length * scale,
      y: vector[1] / length * scale,
      z: vector[2] / length * scale
    };
  }, "normalizeVector");
  var _ShrinkPlayer = class _ShrinkPlayer extends troll_default {
    constructor() {
      super(...arguments);
      __publicField(this, "tick");
    }
    clearTick() {
      if (this.tick !== null) {
        clearTick(this.tick);
        this.tick = null;
      }
    }
    async start() {
      const randomScale = Math.random() * 0.8 + 0.1;
      this.tick = setTick(() => {
        if (cache.vehicle) return;
        const [forward, right, upVector, position] = GetEntityMatrix(cache.ped);
        const forwardNorm = normalizeVector(forward, randomScale);
        const rightNorm = normalizeVector(right, randomScale);
        const upNorm = normalizeVector(upVector, randomScale);
        const entitySpeed = GetEntitySpeed(cache.ped);
        const entityHeightAboveGround = GetEntityHeightAboveGround(cache.ped);
        const adjustedZ = entitySpeed <= 0 && entityHeightAboveGround < 2 ? entityHeightAboveGround - randomScale : GetEntityUprightValue(cache.ped) - randomScale;
        TaskLookAtEntity(cache.ped, cache.ped, 1, 2048, 3);
        SetEntityMatrix(
          cache.ped,
          forwardNorm.x,
          forwardNorm.y,
          forwardNorm.z,
          rightNorm.x,
          rightNorm.y,
          rightNorm.z,
          upNorm.x,
          upNorm.y,
          upNorm.z,
          position[0],
          position[1],
          position[2] - adjustedZ
        );
      });
      return false;
    }
    stop() {
      this.clearTick();
      super.stop();
    }
  };
  __name(_ShrinkPlayer, "ShrinkPlayer");
  var ShrinkPlayer = _ShrinkPlayer;
  var ShrinkPlayer_default = new ShrinkPlayer("shrink_player");

  // src/client/classes/troll/BreakVehicleWheel.ts
  var _BreakVehicleWheel = class _BreakVehicleWheel extends troll_default {
    async start() {
      if (!cache.vehicle) return true;
      if (cache.seat !== -1) return true;
      const numberOfTires = GetVehicleNumberOfWheels(cache.vehicle);
      for (let i = 0; i < numberOfTires; i++) {
        const isTireBurst = IsVehicleWheelBrokenOff(cache.vehicle, i);
        if (!isTireBurst)
          BreakOffVehicleWheel(cache.vehicle, i, true, false, true, false);
      }
      return true;
    }
  };
  __name(_BreakVehicleWheel, "BreakVehicleWheel");
  var BreakVehicleWheel = _BreakVehicleWheel;
  var BreakVehicleWheel_default = new BreakVehicleWheel("breake_vehicle_wheel");

  // src/client/utils/getTrollClass.ts
  function getTrollClass(troll) {
    debugPrint("Getting troll class for:" + troll);
    switch (troll) {
      case "fart_type_1":
        return FartOne_default;
      case "fart_type_2":
        return FartTwo_default;
      case "reverse_control":
        return ReverseControl_default;
      case "fake_lag":
        return FakeLag_default;
      case "random_time_cycle":
        return RandomTimeCycle_default;
      case "ultra_slow_walk":
        return UltraSlowWalk_default;
      case "door_open_close":
        return VehicleDoorOpenClose_default;
      case "nuke_alert_sound":
        return NukeSound_default;
      case "flip_vehicle":
        return FlipVehicle_default;
      case "flip_player":
        return FlipPlayer_default;
      case "flame":
        return FlamePlayer_default;
      case "2d_game":
        return TwoDGame_default;
      case "flip_camera":
        return FlipCamera_default;
      case "clone_follow":
        return CloneFollow_default;
      case "attack_npc":
        return AttackNpc_default;
      case "attack_animal":
        return AttackAnimal_default;
      case "kidnap":
        return Kidnap_default;
      case "ghost":
        return Ghost_default;
      case "ufo_kidnap":
        return UfoKidnap_default;
      case "force_control_player":
        return ForceControl_default;
      case "local_invisibility":
        return LocalInvisiblity_default;
      case "disable_lights":
        return DisableLights_default;
      case "shrink_player":
        return ShrinkPlayer_default;
      case "breake_vehicle_wheel":
        return BreakVehicleWheel_default;
      default:
        return null;
    }
  }
  __name(getTrollClass, "getTrollClass");

  // src/client/classes/ufo/Ufo.ts
  var ufoModel = GetHashKey("p_spinning_anus_s");
  var _Ufo = class _Ufo {
    constructor() {
      __publicField(this, "ufoFlist", /* @__PURE__ */ new Map());
    }
    async spawnUfo(coords, src) {
      const ufoHeight = 200;
      const lightR = 5;
      const ufoCooords = [coords[0], coords[1], coords[2] + ufoHeight];
      const ufoObject = await createObject(ufoModel, ufoCooords, false);
      const tick = setTick(() => {
        DrawMarker(
          1,
          ufoCooords[0],
          ufoCooords[1],
          ufoCooords[2] + 5,
          0,
          0,
          0,
          0,
          180,
          0,
          lightR,
          lightR,
          ufoHeight + 5,
          255,
          255,
          255,
          100,
          false,
          true,
          2,
          false,
          null,
          null,
          false
        );
        DrawLightWithRange(
          coords[0],
          coords[1],
          coords[2] + 0.1,
          255,
          255,
          190,
          lightR,
          1
        );
      });
      this.ufoFlist.set(src, {
        object: ufoObject,
        tick
      });
    }
    deleteUfo(src) {
      const ufoData = this.ufoFlist.get(src);
      if (!ufoData) return;
      if (DoesEntityExist(ufoData.object)) deleteEntity(ufoData.object);
      if (ufoData.tick !== void 0) clearTick(ufoData.tick);
      this.ufoFlist.delete(src);
    }
  };
  __name(_Ufo, "Ufo");
  var Ufo = _Ufo;
  var Ufo_default = new Ufo();

  // src/client/classes/forceControl/ForceControl.ts
  var keyboardKeys = {
    a: 65,
    d: 68,
    s: 83,
    w: 87,
    space: 32
  };
  var _ForceControl2 = class _ForceControl2 {
    constructor() {
      __publicField(this, "players", []);
      __publicField(this, "tickInterval", null);
    }
    createTickInterval() {
      if (this.tickInterval) return;
      this.tickInterval = setTick(() => {
        for (const key in keyboardKeys) {
          const keyId = keyboardKeys[key];
          keyAction(keyId, (action) => {
            if (action === "pressing") return;
            this.players.forEach((src) => {
              debugPrint(
                `Force controlling key: ${key} (${action}) for player src: ${src}`
              );
              emitNet(`${cache.resource}:forceKeyboardControl`, src, key, action);
            });
          });
        }
      });
    }
    clearTickInterval() {
      if (!this.tickInterval) return;
      clearTick(this.tickInterval);
      this.tickInterval = null;
    }
    addPlayer(src) {
      if (!this.players.includes(src)) this.players.push(src);
      this.createTickInterval();
    }
    removePlayer(src) {
      this.players = this.players.filter((playerSrc) => playerSrc !== src);
      if (this.players.length === 0) this.clearTickInterval();
    }
  };
  __name(_ForceControl2, "ForceControl");
  var ForceControl2 = _ForceControl2;
  var ForceControl_default2 = new ForceControl2();

  // src/client/gameStream/index.ts
  RegisterNuiCallback(
    "requestPeerConnection",
    async (data, cb) => {
      cb({});
      emitNet(`${cache.resource}:server:requestPeerConnection`, data);
    }
  );
  onNet(
    `${cache.resource}:client:requestPeerConnection`,
    (data, viewerSrc) => {
      sendNuiMessage("streamMyScreen", { data, viewerSrc });
    }
  );
  RegisterNuiCallback(
    "peerDissconnectMsgToStreamer",
    (data, cb) => {
      emitNet(
        `${cache.resource}:server:peerDissconnectMsgToStreamer`,
        data.playerSrc
      );
      cb({});
    }
  );
  onNet(`${cache.resource}:client:peerDissconnectMsgToStreamer`, () => {
    sendNuiMessage("peerDissconnectMsgToStreamer");
  });
  RegisterNuiCallback(
    "peerDisconnectMsgToViewer",
    (data, cb) => {
      cb({});
      emitNet(
        `${cache.resource}:server:peerDisconnectMsgToViewer`,
        data.viewerSrc
      );
    }
  );
  onNet(`${cache.resource}:client:peerDisconnectMsgToViewer`, () => {
    sendNuiMessage("peerDisconnectMsgToViewer");
  });

  // src/client/index.ts
  var clientPlayer = new Player_default();
  var menuOpenTick = null;
  RegisterNuiCallback("close", (_, cb) => {
    SetNuiFocus(false, false);
    emitNet(`${cache.resource}:closeNui`);
    if (menuOpenTick) {
      setTimeout(() => {
        clearTick(menuOpenTick);
        menuOpenTick = null;
      }, 500);
    }
    cb({});
  });
  RegisterNuiCallback(
    "performAction",
    (data, cb) => {
      debugPrint(`Requesting action ${data.actionType} on player ${data.src}`);
      let variables = {};
      if (data.actionType === "force_control_player") {
        ForceControl_default2.addPlayer(data.src);
        variables = { onlyStopSrc: cache.serverId };
      }
      emitNet(`${cache.resource}:performAction`, data, variables);
      cb({});
    }
  );
  RegisterNuiCallback(
    "stopTrollAction",
    (data, cb) => {
      debugPrint(
        `Requesting stop troll action ${data.actionType} on player ${data.src}`
      );
      if (data.actionType === "force_control_player")
        ForceControl_default2.removePlayer(data.src);
      emitNet(`${cache.resource}:stopTrollAction`, data);
      cb({});
    }
  );
  RegisterNuiCallback(
    "setNuiFocusKeepInput",
    (isActive, cb) => {
      SetNuiFocusKeepInput(isActive);
      cb({});
    }
  );
  onNet(`${cache.resource}:openNui`, (players) => {
    SetNuiFocus(true, true);
    SetNuiFocusKeepInput(true);
    sendNuiMessage("open", players);
    debugPrint("NUI opened");
    debugPrint(JSON.stringify(players));
    menuOpenTick = setTick(() => {
      DisablePlayerFiring(cache.ped, true);
      DisableControlAction(0, 1, true);
      DisableControlAction(0, 2, true);
      DisableControlAction(0, 24, true);
      DisableControlAction(0, 257, true);
      DisableControlAction(0, 263, true);
      DisableControlAction(0, 68, true);
      DisableControlAction(0, 69, true);
      DisableControlAction(0, 92, true);
      DisableControlAction(0, 47, true);
      DisableControlAction(0, 264, true);
      DisableControlAction(0, 257, true);
      DisableControlAction(0, 140, true);
      DisableControlAction(0, 141, true);
      DisableControlAction(0, 142, true);
      DisableControlAction(0, 143, true);
      DisableControlAction(0, 177, true);
      DisableControlAction(0, 200, true);
      DisableFrontendThisFrame();
    });
  });
  onNet(`${cache.resource}:playTroll`, (trollName) => {
    const TrollClass = getTrollClass(trollName);
    if (!TrollClass)
      return console.error(`Troll class for ${trollName} not found`);
    clientPlayer.playTroll(TrollClass);
  });
  onNet(`${cache.resource}:stopTroll`, (trollName) => {
    const TrollClass = getTrollClass(trollName);
    if (!TrollClass)
      return console.error(`Troll class for ${trollName} not found`);
    clientPlayer.stopTroll(TrollClass);
  });
  onNet(
    `${cache.resource}:actionPerformed`,
    (data) => {
      sendNuiMessage("actionPerformed", data);
    }
  );
  onNet(
    `${cache.resource}:trollStopped`,
    (data) => {
      sendNuiMessage("trollStopped", data);
    }
  );
  onNet(`${cache.resource}:playerDisconnected`, (src) => {
    sendNuiMessage("playerDisconnected", src);
    debugPrint(`Player disconnected (src: ${src})`);
  });
  onNet(`${cache.resource}:playerConnected`, (player) => {
    sendNuiMessage("playerConnected", player);
    debugPrint(`Player connected: ${player.name} (src: ${player.src})`);
  });
  onNet(
    `${cache.resource}:playerNameUpdated`,
    (data) => {
      sendNuiMessage("playerNameUpdated", data);
    }
  );
  onNet(`${cache.resource}:client:spawnUfo`, (coords, src) => {
    Ufo_default.spawnUfo(coords, src);
  });
  onNet(`${cache.resource}:client:deleteUfo`, (src) => {
    Ufo_default.deleteUfo(src);
  });
  var init = /* @__PURE__ */ __name(() => {
    emitNet(`${cache.resource}:playerConnected`);
  }, "init");
  setTimeout(init, 1e3);
  RegisterKeyMapping(
    "openTrollMenu",
    "Toggle Troll Menu (Admin)",
    "keyboard",
    config_default.keybind
  );
  RegisterCommand(
    "openTrollMenu",
    () => emitNet(`${cache.resource}:tryOpenMenu`),
    false
  );
})();
