var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// node_modules/.pnpm/@communityox+ox_lib@3.30.7/node_modules/@communityox/ox_lib/server/resource/acl/index.js
var addAce = /* @__PURE__ */ __name((principal, ace, allow) => exports.ox_lib.addAce(principal, ace, allow), "addAce");

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

// node_modules/.pnpm/@communityox+ox_lib@3.30.7/node_modules/@communityox/ox_lib/server/resource/addCommand/index.js
var registeredCommmands = [];
var shouldSendCommands = false;
setTimeout(() => {
  shouldSendCommands = true;
  emitNet("chat:addSuggestions", -1, registeredCommmands);
}, 1e3);
on("playerJoining", () => {
  emitNet("chat:addSuggestions", source, registeredCommmands);
});
function parseArguments(source2, args, raw, params) {
  if (!params)
    return args;
  const result = params.every((param, index) => {
    const arg = args[index];
    let value;
    switch (param.paramType) {
      case "number":
        value = +arg;
        break;
      case "string":
        value = !Number(arg) ? arg : false;
        break;
      case "playerId":
        value = arg === "me" ? source2 : +arg;
        if (!value || !DoesPlayerExist(value.toString()))
          value = false;
        break;
      case "longString":
        value = raw.substring(raw.indexOf(arg));
        break;
      default:
        value = arg;
        break;
    }
    if (value === void 0 && (!param.optional || param.optional && arg)) {
      return Citizen.trace(`^1command '${raw.split(" ")[0] || raw}' received an invalid ${param.paramType} for argument ${index + 1} (${param.name}), received '${arg}'^0`);
    }
    args[param.name] = value;
    delete args[index];
    return true;
  });
  return result ? args : void 0;
}
__name(parseArguments, "parseArguments");
function addCommand(commandName, cb, properties) {
  const restricted = properties?.restricted;
  const params = properties?.params;
  if (params) {
    params.forEach((param) => {
      if (param.paramType)
        param.help = param.help ? `${param.help} (type: ${param.paramType})` : `(type: ${param.paramType})`;
    });
  }
  const commands = typeof commandName !== "object" ? [commandName] : commandName;
  const numCommands = commands.length;
  const commandHandler = /* @__PURE__ */ __name((source2, args, raw) => {
    const parsed = parseArguments(source2, args, raw, params);
    if (!parsed)
      return;
    cb(source2, parsed, raw).catch((e) => Citizen.trace(`^1command '${raw.split(" ")[0] || raw}' failed to execute!^0
${e.message}`));
  }, "commandHandler");
  commands.forEach((commandName2, index) => {
    RegisterCommand(commandName2, commandHandler, restricted ? true : false);
    if (restricted) {
      const ace = `command.${commandName2}`;
      const restrictedType = typeof restricted;
      if (restrictedType === "string" && !IsPrincipalAceAllowed(restricted, ace)) {
        addAce(restricted, ace, true);
      } else if (restrictedType === "object") {
        const _restricted = restricted;
        _restricted.forEach((principal) => {
          if (!IsPrincipalAceAllowed(principal, ace))
            addAce(principal, ace, true);
        });
      }
    }
    if (properties) {
      properties.name = `/${commandName2}`;
      delete properties.restricted;
      registeredCommmands.push(properties);
      if (index !== numCommands && numCommands !== 1)
        properties = { ...properties };
      if (shouldSendCommands)
        emitNet("chat:addSuggestions", -1, properties);
    }
  });
}
__name(addCommand, "addCommand");

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

// src/server/classes/serverPlayerList/serverPlayerList.ts
var ServerPlayerList = class {
  static {
    __name(this, "ServerPlayerList");
  }
  players = /* @__PURE__ */ new Map();
  playerIsAdded(src) {
    return this.players.has(src);
  }
  addPlayer(src, player, adminFunc) {
    if (this.playerIsAdded(src)) return;
    this.players.set(src, player);
    if (adminFunc) adminFunc(`${cache.resource}:playerConnected`, player);
    debugPrint(`Player added: ${player.name} (src: ${src})`);
  }
  removePlayer(src, adminFunc) {
    if (!this.playerIsAdded(src)) return;
    this.players.delete(src);
    if (adminFunc) adminFunc(`${cache.resource}:playerDisconnected`, src);
    debugPrint(`Player removed (src: ${src})`);
  }
  getPlayer(src) {
    if (!this.playerIsAdded(src)) return null;
    return this.players.get(src);
  }
  getAllPlayers() {
    return this.players;
  }
  getAllEntities() {
    let entites = [];
    this.players.forEach((player) => {
      entites = [...entites, ...player.getAllEntities()];
    });
    return entites;
  }
};
var global2 = new ServerPlayerList();
var serverPlayerList_default = global2;

// src/server/classes/serverPlayer/serverPlayer.ts
var ServerPlayer = class {
  static {
    __name(this, "ServerPlayer");
  }
  src;
  name;
  activeTrolls = [];
  trollVariables = /* @__PURE__ */ new Map();
  entityList = [];
  id;
  constructor(src) {
    this.src = src;
    const stringSrc = src.toString();
    this.name = `[${src}] ${GetPlayerName(stringSrc) || "Unknown"}`;
    this.id = GetPlayerIdentifierByType(stringSrc, "steam") || GetPlayerIdentifierByType(stringSrc, "licance") || GetPlayerIdentifierByType(stringSrc, "licance2");
  }
  updatePlayerName(name) {
    this.name = name;
    debugPrint(`Player name updated to: ${name} (src: ${this.src})`);
  }
  addEntity(netId) {
    this.entityList = [...this.entityList, netId];
    debugPrint(`Entity spawned with netId: ${netId} (src: ${this.src})`);
  }
  getAllEntities() {
    return this.entityList;
  }
  isEntityOwnedByPlayer(netId) {
    return this.entityList.includes(netId);
  }
  removeEntity(netId) {
    this.entityList = this.entityList.filter((id) => id !== netId);
    debugPrint(`Entity removed with netId: ${netId} (src: ${this.src})`);
  }
  playerIsOnline() {
    return GetPlayerName(this.src.toString()) !== null;
  }
  trollIsActive(troll) {
    return this.activeTrolls.includes(troll);
  }
  playTroll(troll, variables) {
    if (this.trollIsActive(troll)) return [false, "trollActive"];
    if (!this.playerIsOnline()) return [false, "playerOffline"];
    this.activeTrolls.push(troll);
    this.trollVariables.set(troll, variables);
    emitNet(`${cache.resource}:playTroll`, this.src, troll);
    return [true, null];
  }
  stopTroll(troll) {
    if (!this.trollIsActive(troll)) return;
    emitNet(`${cache.resource}:stopTroll`, this.src, troll);
  }
  trollStopped(troll) {
    if (!this.trollIsActive(troll)) return;
    this.activeTrolls = this.activeTrolls.filter((t) => t !== troll);
    this.trollVariables.delete(troll);
  }
  getTrollVariables(troll) {
    return this.trollVariables.get(troll) || null;
  }
};
var serverPlayer_default = ServerPlayer;

// src/server/classes/menuOpenedAdminList/adminList.ts
var MenuOpenedAdminList = class {
  static {
    __name(this, "MenuOpenedAdminList");
  }
  admins = [];
  isAddedAdmin(src) {
    return this.admins.includes(src);
  }
  addAdmin(src) {
    if (this.isAddedAdmin(src)) return;
    this.admins.push(src);
  }
  removeAdmin(src) {
    if (!this.isAddedAdmin(src)) return;
    this.admins = this.admins.filter((admin) => admin !== src);
  }
  emitNetToAdmins(eventName, ...args) {
    this.admins.map((admin) => emitNet(eventName, admin, ...args));
  }
};
var global3 = new MenuOpenedAdminList();
var adminList_default = global3;

// src/server/utils/index.ts
function isAdmin(source2) {
  return IsPlayerAceAllowed(source2.toString(), config_default.adminGroup);
}
__name(isAdmin, "isAdmin");

// src/server/gameStream/index.ts
onNet(
  `${cache.resource}:server:requestPeerConnection`,
  (data) => {
    const playerId = global.source;
    if (!isAdmin(playerId)) return;
    emitNet(
      `${cache.resource}:client:requestPeerConnection`,
      data.targetSrc,
      data,
      global.source
    );
  }
);
onNet(
  `${cache.resource}:server:peerDissconnectMsgToStreamer`,
  (playerServerId) => {
    emitNet(
      `${cache.resource}:client:peerDissconnectMsgToStreamer`,
      playerServerId
    );
  }
);
onNet(
  `${cache.resource}:server:peerDisconnectMsgToViewer`,
  (playerServerId) => {
    emitNet(
      `${cache.resource}:client:peerDisconnectMsgToViewer`,
      playerServerId
    );
  }
);

// src/server/index.ts
var openMenu = /* @__PURE__ */ __name(async (playerId) => {
  if (!playerId) return;
  if (!isAdmin(playerId)) return;
  const allPlayers = serverPlayerList_default.getAllPlayers();
  emitNet(
    `${cache.resource}:openNui`,
    playerId,
    Array.from(allPlayers.values())
  );
  adminList_default.addAdmin(playerId);
}, "openMenu");
addCommand("troll", openMenu, {
  help: "Open the admin troll menu",
  restricted: config_default.adminGroup
});
onNet(`${cache.resource}:tryOpenMenu`, () => openMenu(global.source));
onNet(`${cache.resource}:closeNui`, () => {
  const playerId = global.source;
  adminList_default.removeAdmin(playerId);
});
onNet(`${cache.resource}:playerConnected`, () => {
  const playerId = global.source;
  const serverPlayer = new serverPlayer_default(playerId);
  serverPlayerList_default.addPlayer(
    playerId,
    serverPlayer,
    adminList_default.emitNetToAdmins.bind(adminList_default)
  );
});
on("playerDropped", () => {
  const playerId = global.source;
  adminList_default.removeAdmin(playerId);
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  const entityList = serverPlayer.getAllEntities();
  for (const netId of entityList) {
    const entity = NetworkGetEntityFromNetworkId(netId);
    if (!entity || !DoesEntityExist(entity)) continue;
    DeleteEntity(entity);
  }
  serverPlayerList_default.removePlayer(
    playerId,
    adminList_default.emitNetToAdmins.bind(adminList_default)
  );
});
onNet(
  `${cache.resource}:performAction`,
  (data, variables) => {
    const playerId = global.source;
    if (!isAdmin(playerId)) return;
    const { actionType, src } = data;
    const serverPlayer = serverPlayerList_default.getPlayer(src);
    if (!serverPlayer) return;
    debugPrint(
      `Performing action ${actionType} on player ${serverPlayer.name} (src: ${src})`
    );
    const [success] = serverPlayer.playTroll(actionType, variables);
    if (!success) return;
    adminList_default.emitNetToAdmins(`${cache.resource}:actionPerformed`, {
      trollName: actionType,
      src
    });
  }
);
onNet(`${cache.resource}:stopTrollAction`, (data) => {
  const playerId = global.source;
  if (!isAdmin(playerId)) return;
  const { actionType, src } = data;
  const serverPlayer = serverPlayerList_default.getPlayer(src);
  if (!serverPlayer) return;
  const actionVars = serverPlayer.getTrollVariables(actionType);
  if (actionVars) {
    if (actionVars.onlyStopSrc && actionVars.onlyStopSrc !== playerId) return;
  }
  serverPlayer.stopTroll(actionType);
});
onNet(`${cache.resource}:trolStopped`, (trollName) => {
  const playerId = global.source;
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  serverPlayer.trollStopped(trollName);
  adminList_default.emitNetToAdmins(`${cache.resource}:trollStopped`, {
    trollName,
    src: playerId
  });
});
onNet(`${cache.resource}:playSound`, (soundFile) => {
  const playerId = global.source;
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  if (!serverPlayer.trollIsActive("fart_type_1") && !serverPlayer.trollIsActive("fart_type_2"))
    return;
  const playerState = Player(global.source);
  playerState.state.set("tgiann_troll_sound", soundFile, true);
});
onNet(`${cache.resource}:stopSound`, () => {
  const playerState = Player(global.source);
  playerState.state.set("tgiann_troll_sound", false, true);
});
onNet(`${cache.resource}:entitySpawned`, (netId) => {
  const playerId = global.source;
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  serverPlayer.addEntity(netId);
});
onNet(`${cache.resource}:deleteEntity`, (netId) => {
  const playerId = global.source;
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  if (!serverPlayer.isEntityOwnedByPlayer(netId)) return;
  const entity = NetworkGetEntityFromNetworkId(netId);
  if (!entity || !DoesEntityExist(entity)) return;
  DeleteEntity(entity);
  serverPlayer.removeEntity(netId);
});
onNet(`${cache.resource}:server:spawnUfo`, (coords) => {
  const playerId = global.source;
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  if (!serverPlayer.trollIsActive("ufo_kidnap")) return;
  emitNet(`${cache.resource}:client:spawnUfo`, -1, coords, global.source);
});
onNet(`${cache.resource}:server:deleteUfo`, () => {
  emitNet(`${cache.resource}:client:deleteUfo`, -1, global.source);
});
onNet(
  `${cache.resource}:forceKeyboardControl`,
  (src, key, action) => {
    const playerId = global.source;
    if (!isAdmin(playerId)) return;
    emitNet(`${cache.resource}:forceControlApply`, src, key, action);
  }
);
onNet("esx:playerLoaded", (playerId, xPlayer, _) => {
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  if (!xPlayer.name) return;
  const name = `[${playerId}] ${xPlayer.name}`;
  serverPlayer.updatePlayerName(name);
  adminList_default.emitNetToAdmins(`${cache.resource}:playerNameUpdated`, {
    name,
    src: playerId
  });
});
onNet("QBCore:Server:PlayerLoaded", (xPlayer) => {
  const playerId = xPlayer.PlayerData.source;
  const serverPlayer = serverPlayerList_default.getPlayer(playerId);
  if (!serverPlayer) return;
  const name = `[${playerId}] ${xPlayer.PlayerData.charinfo.firstname} ${xPlayer.PlayerData.charinfo.lastname}`;
  serverPlayer.updatePlayerName(name);
  adminList_default.emitNetToAdmins(`${cache.resource}:playerNameUpdated`, {
    name,
    src: playerId
  });
});
on("onResourceStop", (resourceName) => {
  if (cache.resource !== resourceName) return;
  const allEntities = serverPlayerList_default.getAllEntities();
  for (const netId of allEntities) {
    const entity = NetworkGetEntityFromNetworkId(netId);
    if (!entity || !DoesEntityExist(entity)) continue;
    DeleteEntity(entity);
  }
  debugPrint(
    `Resource stopping, deleting ${allEntities.length} entities spawned by troll actions.`
  );
});
