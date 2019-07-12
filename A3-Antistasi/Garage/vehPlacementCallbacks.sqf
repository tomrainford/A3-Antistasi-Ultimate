#include "defineCommon.inc"
params ["_callbackTarget", "_callbackType", ["_callbackParams", []]];

/* 
CALLBACK_VEH_PLACED_SUCCESSFULLY - Passed the created vehicle, no return needed
CALLBACK_VEH_PLACEMENT_CANCELLED - No parameters, no return needed
CALLBACK_SHOULD_CANCEL_PLACEMENT - Passed a temporary preview vehicle, return format [shouldCancel: bool, messageOnCancel: string]
CALLBACK_CAN_PLACE_VEH - Passed a temporary preview vehicle, return format [canPlace: bool, messageOnUnableTo: string]
CALLBACK_VEH_PLACEMENT_CLEANUP - Passed nothing, no return needed. Called just before vehicle placement totally finishes. Should always be called.
*/

switch (_callbackTarget) do {
	case "GARAGE": {
		switch (_callbackType) do {
			case CALLBACK_VEH_PLACEMENT_CLEANUP: {
				garageIsOpen = false;
			};
		
			case CALLBACK_VEH_PLACEMENT_CANCELLED: {
			};
		
			case CALLBACK_SHOULD_CANCEL_PLACEMENT: {
				if (!(player inArea garage_nearestMarker)) exitWith {
					[true, "You need to be close to one of your garrisons to be able to retrieve a vehicle from your garage"];
				};
				[false];
			};
		
			case CALLBACK_CAN_PLACE_VEH: {
				private _previewVeh = _callbackParams select 0;
				if (_previewVeh distance2d player > 50) exitWith 
				{
					[false, "Vehicles must be placed within 50m of the flag"];
				};
				if (!(player inArea garage_nearestMarker)) exitWith 
				{
					[false, "You need to be close to one of your garrisons to be able to retrieve a vehicle from your garage"];
				};
				if ([player,300] call A3A_fnc_enemyNearCheck) exitWith
				{
					[false, "You cannot manage the Garage with enemies nearby"];
				};
				[true];
			};
		
			case CALLBACK_VEH_PLACED_SUCCESSFULLY: {
				private _garageVeh = _callbackParams param [0];
				[_garageVeh] call A3A_fnc_AIVEHinit;

				if (_garageVeh isKindOf "Car") then {_garageVeh setPlateNumber format ["%1",name player]};
				
				//Handle Garage removal
				private _newArr = [];
				private _found = false;
				if (garage_mode == GARAGE_FACTION) then
					{
					{
						if ((_x != (garage_vehiclesAvailable select garage_vehicleIndex)) or (_found)) then {_newArr pushBack _x} else {_found = true};
					} forEach vehInGarage;
					vehInGarage = _newArr;
					publicVariable "vehInGarage";
					}
				else
					{
					{
						if ((_x != (garage_vehiclesAvailable select garage_vehicleIndex)) or (_found)) then {_newArr pushBack _x} else {_found = true};
					} forEach personalGarage;
					personalGarage = _newArr;
					["personalGarage",_newArr] call fn_SaveStat;
					_garageVeh setVariable ["ownerX",getPlayerUID player,true];
					};
				if (_garageVeh isKindOf "StaticWeapon") then {staticsToSave pushBack _garageVeh; publicVariable "staticsToSave"};
			};
		};
	};
	
	default {
		switch (_callbackType) do {
			case CALLBACK_VEH_PLACEMENT_CLEANUP: {
				//No return needed
			};
		
			case CALLBACK_VEH_PLACEMENT_CANCELLED: {
				//No return needed
			};
		
			case CALLBACK_SHOULD_CANCEL_PLACEMENT: {
				[false];
			};
		
			case CALLBACK_CAN_PLACE_VEH: {
				[true];
			};
		
			case CALLBACK_VEH_PLACED_SUCCESSFULLY: {
				//No return needed.
			};
		};
	};
};