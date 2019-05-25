if (!isServer) exitWith {};
private ["_subObject","_ammunition","_originX","_destinationX"];
_originX = _this select 0;
if (isNull _originX) exitWith {};
_destinationX = _this select 1;

_ammunition= [];
_items = [];
_ammunition = magazineCargo _originX;
_items = itemCargo _originX;
_armas = [];
_weaponsItemsCargo = weaponsItemsCargo _originX;
_backpcks = [];

if (count backpackCargo _originX > 0) then
	{
	{
	_backpcks pushBack (_x call BIS_fnc_basicBackpack);
	} forEach backpackCargo _originX;
	};
_containers = everyContainer _originX;
if (count _containers > 0) then
	{
	for "_i" from 0 to (count _containers) - 1 do
		{
		_subObject = magazineCargo ((_containers select _i) select 1);
		if (!isNil "_subObject") then {_ammunition = _ammunition + _subObject} else {diag_log format ["Error from %1",magazineCargo (_containers select _i)]};
		//_ammunition = _ammunition + (magazineCargo ((_containers select _i) select 1));
		_items = _items + (itemCargo ((_containers select _i) select 1));
		_weaponsItemsCargo = _weaponsItemsCargo + weaponsItemsCargo ((_containers select _i) select 1);
		};
	};
if (!isNil "_weaponsItemsCargo") then
	{
	if (count _weaponsItemsCargo > 0) then
		{
		{
		_armas pushBack ([(_x select 0)] call BIS_fnc_baseWeapon);
		for "_i" from 1 to (count _x) - 1 do
			{
			_cosa = _x select _i;
			if (typeName _cosa == typeName "") then
				{
				if (_cosa != "") then {_items pushBack _cosa};
				};
			};
		} forEach _weaponsItemsCargo;
		};
	};

_armasFinal = [];
_armasFinalCount = [];
{
_arma = _x;
if ((not(_arma in _armasFinal)) and (not(_arma in unlockedWeapons))) then
	{
	_armasFinal pushBack _arma;
	_armasFinalCount pushBack ({_x == _arma} count _armas);
	};
} forEach _armas;

if (count _armasFinal > 0) then
	{
	for "_i" from 0 to (count _armasFinal) - 1 do
		{
		_destinationX addWeaponCargoGlobal [_armasFinal select _i,_armasFinalCount select _i];
		};
	};

_ammunitionFinal = [];
_ammunitionFinalCount = [];
if (isNil "_ammunition") then
	{
	diag_log format ["Error en transmisión de munición. Tenía esto: %1 y estos containers: %2, el originX era un %3 y el objeto está definido como: %4", magazineCargo _originX, everyContainer _originX,typeOf _originX,_originX];
	}
else
	{
	{
	_arma = _x;
	if ((not(_arma in _ammunitionFinal)) and (not(_arma in unlockedMagazines))) then
		{
		_ammunitionFinal pushBack _arma;
		_ammunitionFinalCount pushBack ({_x == _arma} count _ammunition);
		};
	} forEach  _ammunition;
	};


if (count _ammunitionFinal > 0) then
	{
	for "_i" from 0 to (count _ammunitionFinal) - 1 do
		{
		_destinationX addMagazineCargoGlobal [_ammunitionFinal select _i,_ammunitionFinalCount select _i];
		};
	};

_itemsFinal = [];
_itemsFinalCount = [];
{
_arma = _x;
if ((not(_arma in _itemsFinal)) and (not(_arma in unlockedItems))) then
	{
	_itemsFinal pushBack _arma;
	_itemsFinalCount pushBack ({_x == _arma} count _items);
	};
} forEach _items;

if (count _itemsFinal > 0) then
	{
	for "_i" from 0 to (count _itemsFinal) - 1 do
		{
		_destinationX addItemCargoGlobal [_itemsFinal select _i,_itemsFinalCount select _i];
		};
	};

_backpcksFinal = [];
_backpcksFinalCount = [];
{
_arma = _x;
if ((not(_arma in _backpcksFinal)) and (not(_arma in unlockedBackpacks))) then
	{
	_backpcksFinal pushBack _arma;
	_backpcksFinalCount pushBack ({_x == _arma} count _backpcks);
	};
} forEach _backpcks;

if (count _backpcksFinal > 0) then
	{
	for "_i" from 0 to (count _backpcksFinal) - 1 do
		{
		_destinationX addBackpackCargoGlobal [_backpcksFinal select _i,_backpcksFinalCount select _i];
		};
	};

if (count _this == 3) then
	{
	deleteVehicle _originX;
	}
else
	{
	clearMagazineCargoGlobal _originX;
	clearWeaponCargoGlobal _originX;
	clearItemCargoGlobal _originX;
	clearBackpackCargoGlobal _originX;
	};

if (_destinationX == caja) then
	{
	if (isMultiplayer) then {{if (_x distance caja < 10) then {[petros,"hint","Ammobox Loaded"] remoteExec ["A3A_fnc_commsMP",_x]}} forEach playableUnits} else {hint "Ammobox Loaded"};
	if ((_originX isKindOf "ReammoBox_F") and (_originX != vehicleBox)) then {deleteVehicle _originX};
	_updated = [] call A3A_fnc_arsenalManage;
	if (_updated != "") then
		{
		_updated = format ["Arsenal Updated<br/><br/>%1",_updated];
		[petros,"income",_updated] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
		};
	}
else
	{
	[petros,"hint","Truck Loaded"] remoteExec ["A3A_fnc_commsMP",driver _destinationX];
	};