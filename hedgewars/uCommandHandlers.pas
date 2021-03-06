(*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2004-2011 Andrey Korotaev <unC0Rr@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 *)

{$INCLUDE "options.inc"}

unit uCommandHandlers;

interface

procedure initModule;
procedure freeModule;

implementation
uses uCommands, uTypes, uVariables, uIO, uDebug, uConsts, uScript, uUtils, SDLh, uRandom;

procedure chGenCmd(var s: shortstring);
begin
case s[1] of
     'R': if ReadyTimeLeft > 1 then 
          begin
          ReadyTimeLeft:= 1;
          if not CurrentTeam^.ExtDriven then SendIPC('c'+s);
          end
    end
end;

procedure chQuit(var s: shortstring);
const prevGState: TGameState = gsConfirm;
begin
    s:= s; // avoid compiler hint
    if GameState <> gsConfirm then
    begin
        prevGState:= GameState;
        GameState:= gsConfirm
    end else
    GameState:= prevGState
end;

procedure chForceQuit(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    GameState:= gsConfirm;
    ParseCommand('confirm', true);
end;

procedure chConfirm(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    if GameState = gsConfirm then
    begin
        SendIPC('Q');
        GameState:= gsExit
    end
else
    ParseCommand('chat team', true);
end;

procedure chHalt (var s: shortstring);
begin
    s:= s; // avoid compiler hint
    SendIPC('H');
    GameState:= gsExit
end;

procedure chCheckProto(var s: shortstring);
var i, c: LongInt;
begin
if isDeveloperMode then
begin
val(s, i, c);
if (c <> 0) or (i = 0) then exit;
TryDo(i <= cNetProtoVersion, 'Protocol version mismatch: engine is too old', true);
TryDo(i >= cNetProtoVersion, 'Protocol version mismatch: engine is too new', true)
end
end;

procedure chTeamLocal(var s: shortstring);
begin
s:= s; // avoid compiler hint
if not isDeveloperMode then exit;
if CurrentTeam = nil then OutError(errmsgIncorrectUse + ' "/rdriven"', true);
CurrentTeam^.ExtDriven:= true
end;

procedure chGrave(var s: shortstring);
begin
if CurrentTeam = nil then OutError(errmsgIncorrectUse + ' "/grave"', true);
if s[1]='"' then Delete(s, 1, 1);
if s[byte(s[0])]='"' then Delete(s, byte(s[0]), 1);
CurrentTeam^.GraveName:= s
end;

procedure chFort(var s: shortstring);
begin
if CurrentTeam = nil then OutError(errmsgIncorrectUse + ' "/fort"', true);
if s[1]='"' then Delete(s, 1, 1);
if s[byte(s[0])]='"' then Delete(s, byte(s[0]), 1);
CurrentTeam^.FortName:= s
end;

procedure chFlag(var s: shortstring);
begin
if CurrentTeam = nil then OutError(errmsgIncorrectUse + ' "/flag"', true);
if s[1]='"' then Delete(s, 1, 1);
if s[byte(s[0])]='"' then Delete(s, byte(s[0]), 1);
CurrentTeam^.flag:= s
end;

procedure chScript(var s: shortstring);
begin
if s[1]='"' then Delete(s, 1, 1);
if s[byte(s[0])]='"' then Delete(s, byte(s[0]), 1);
ScriptLoad(s)
end;

procedure chSetHat(var s: shortstring);
begin
if (not isDeveloperMode) or (CurrentTeam = nil) then exit;
with CurrentTeam^ do
    begin
    if not CurrentHedgehog^.King then
    if (s = '') or
        (((GameFlags and gfKing) <> 0) and (s = 'crown')) or
        ((Length(s) > 39) and (Copy(s,1,8) = 'Reserved') and (Copy(s,9,32) <> PlayerHash)) then
        CurrentHedgehog^.Hat:= 'NoHat'
    else
        CurrentHedgehog^.Hat:= s
    end;
end;

procedure chCurU_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementY:= -1;
end;

procedure chCurU_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementY:= 0;
end;

procedure chCurD_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementY:= 1;
end;

procedure chCurD_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementY:= 0;
end;

procedure chCurL_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementX:= -1;
end;

procedure chCurL_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementX:= 0;
end;

procedure chCurR_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementX:= 1;
end;

procedure chCurR_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
CursorMovementX:= 0;
end;

procedure chLeft_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('L');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmLeft and InputMask);
    ScriptCall('onLeft');
end;

procedure chLeft_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then exit;
if not CurrentTeam^.ExtDriven then SendIPC('l');
with CurrentHedgehog^.Gear^ do
    Message:= Message and not (gmLeft and InputMask);
    ScriptCall('onLeftUp');
end;

procedure chRight_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('R');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmRight and InputMask);
    ScriptCall('onRight');
end;

procedure chRight_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then exit;
if not CurrentTeam^.ExtDriven then SendIPC('r');
with CurrentHedgehog^.Gear^ do
    Message:= Message and not (gmRight and InputMask);
    ScriptCall('onRightUp');
end;

procedure chUp_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('U');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmUp and InputMask);
    ScriptCall('onUp');
end;

procedure chUp_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then exit;
if not CurrentTeam^.ExtDriven then SendIPC('u');
with CurrentHedgehog^.Gear^ do
    Message:= Message and not (gmUp and InputMask);
    ScriptCall('onUpUp');
end;

procedure chDown_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('D');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmDown and InputMask);
    ScriptCall('onDown');
end;

procedure chDown_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then exit;
if not CurrentTeam^.ExtDriven then SendIPC('d');
with CurrentHedgehog^.Gear^ do
    Message:= Message and not (gmDown and InputMask);
    ScriptCall('onDownUp');
end;

procedure chPrecise_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('Z');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmPrecise and InputMask);
    ScriptCall('onPrecise');
end;

procedure chPrecise_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then exit;
if not CurrentTeam^.ExtDriven then SendIPC('z');
with CurrentHedgehog^.Gear^ do
    Message:= Message and not (gmPrecise and InputMask);
    ScriptCall('onPreciseUp');
end;

procedure chLJump(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('j');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmLJump and InputMask);
    ScriptCall('onLJump');
end;

procedure chHJump(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('J');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmHJump and InputMask);
    ScriptCall('onHJump');
end;

procedure chAttack_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    begin
    AddFileLog('/+attack: hedgehog''s Gear^.State = '+inttostr(State));
    if ((State and gstHHDriven) <> 0) then
        begin
        FollowGear:= CurrentHedgehog^.Gear;
        if not CurrentTeam^.ExtDriven then SendIPC('A');
        Message:= Message or (gmAttack and InputMask);
	ScriptCall('onAttack');
        end
    end
end;

procedure chAttack_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then exit;
with CurrentHedgehog^.Gear^ do
    begin
    if not CurrentTeam^.ExtDriven and
        ((Message and gmAttack) <> 0) then SendIPC('a');
    Message:= Message and not (gmAttack and InputMask);
    ScriptCall('onAttackUp');
    end
end;

procedure chSwitch(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
if not CurrentTeam^.ExtDriven then SendIPC('S');
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    Message:= Message or (gmSwitch and InputMask);
    ScriptCall('onSwitch');
end;

procedure chNextTurn(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    TryDo(AllInactive, '/nextturn called when not all gears are inactive', true);

    if not CurrentTeam^.ExtDriven then SendIPC('N');
    AddFileLog('Doing SwitchHedgehog: time '+inttostr(GameTicks));
end;

procedure chTimer(var s: shortstring);
begin
if (s[0] <> #1) or (s[1] < '1') or (s[1] > '5') or CheckNoTeamOrHH then exit;

if not CurrentTeam^.ExtDriven then SendIPC(s);
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    begin
    Message:= Message or (gmTimer and InputMask);
    MsgParam:= byte(s[1]) - ord('0');
    ScriptCall('onTimer');
    end
end;

procedure chSlot(var s: shortstring);
var slot: LongWord;
begin
if (s[0] <> #1) or CheckNoTeamOrHH then exit;
slot:= byte(s[1]) - 49;
if slot > cMaxSlotIndex then exit;
if not CurrentTeam^.ExtDriven then SendIPC(char(byte(s[1]) + 79));
bShowFinger:= false;
with CurrentHedgehog^.Gear^ do
    begin
    Message:= Message or (gmSlot and InputMask);
    MsgParam:= slot; 
    ScriptCall('onSlot');
    end
end;

procedure chSetWeapon(var s: shortstring);
begin
    if (s[0] <> #1) or CheckNoTeamOrHH then exit;

    if TAmmoType(s[1]) > High(TAmmoType) then exit;

    if not CurrentTeam^.ExtDriven then SendIPC('w' + s);

    with CurrentHedgehog^.Gear^ do
    begin
        Message:= Message or (gmWeapon and InputMask);
        MsgParam:= byte(s[1]);
	ScriptCall('onSetWeapon');
    end;
end;

procedure chTaunt(var s: shortstring);
begin
if (s[0] <> #1) or CheckNoTeamOrHH then exit;

if TWave(s[1]) > High(TWave) then exit;

if not CurrentTeam^.ExtDriven then SendIPC('t' + s);

with CurrentHedgehog^.Gear^ do
    begin
    Message:= Message or (gmAnimate and InputMask);
    MsgParam:= byte(s[1]) ; 
    ScriptCall('onTaunt');
    end
end;

procedure chPut(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    doPut(0, 0, false);
end;

procedure chCapture(var s: shortstring);
begin
s:= s; // avoid compiler hint
flagMakeCapture:= true
end;

procedure chSetMap(var s: shortstring);
begin
if isDeveloperMode then
begin
Pathz[ptMapCurrent]:= Pathz[ptMaps] + '/' + s;
InitStepsFlags:= InitStepsFlags or cifMap
end
end;

procedure chSetTheme(var s: shortstring);
begin
if isDeveloperMode then
begin
Pathz[ptCurrTheme]:= Pathz[ptThemes] + '/' + s;
Theme:= s;
InitStepsFlags:= InitStepsFlags or cifTheme
end
end;

procedure chSetSeed(var s: shortstring);
begin
if isDeveloperMode then
begin
SetRandomSeed(s);
cSeed:= s;
InitStepsFlags:= InitStepsFlags or cifRandomize
end
end;

procedure chAmmoMenu(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH then
    bShowAmmoMenu:= true
else
    begin
    with CurrentTeam^ do
        with Hedgehogs[CurrHedgehog] do
            begin
            bSelected:= false;

            if bShowAmmoMenu then bShowAmmoMenu:= false
            else if ((Gear^.State and (gstAttacking or gstAttacked)) <> 0) or
                    ((MultiShootAttacks > 0) and ((Ammoz[CurAmmoType].Ammo.Propz and ammoprop_NoRoundEnd) = 0)) or
                    ((Gear^.State and gstHHDriven) = 0) then else bShowAmmoMenu:= true
            end;
    end
end;

procedure chVol_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
inc(cVolumeDelta, 3)
end;

procedure chVol_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
dec(cVolumeDelta, 3)
end;

procedure chFindhh(var s: shortstring);
begin
s:= s; // avoid compiler hint
if CheckNoTeamOrHH or isPaused then exit;
bShowFinger:= true;
FollowGear:= CurrentHedgehog^.Gear
end;

procedure chPause(var s: shortstring);
begin
s:= s; // avoid compiler hint
if gameType <> gmtNet then
    isPaused:= not isPaused;
SDL_ShowCursor(ord(isPaused))
end;

procedure chRotateMask(var s: shortstring);
begin
s:= s; // avoid compiler hint
if ((GameFlags and gfInvulnerable) = 0) then cTagsMask:= cTagsMasks[cTagsMask] else cTagsMask:= cTagsMasksNoHealth[cTagsMask];
end;

procedure chSpeedup_p(var s: shortstring);
begin
s:= s; // avoid compiler hint
isSpeed:= true
end;

procedure chSpeedup_m(var s: shortstring);
begin
s:= s; // avoid compiler hint
isSpeed:= false
end;

procedure chZoomIn(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    if ZoomValue < cMinZoomLevel then
        ZoomValue:= ZoomValue + cZoomDelta;
end;

procedure chZoomOut(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    if ZoomValue > cMaxZoomLevel then
        ZoomValue:= ZoomValue - cZoomDelta;
end;

procedure chZoomReset(var s: shortstring);
begin
    s:= s; // avoid compiler hint
    ZoomValue:= cDefaultZoomLevel;
end;


procedure initModule;
begin
//////// Begin top sorted by freq analysis not including chatmsg
    RegisterVariable('+right'  , vtCommand, @chRight_p      , false);
    RegisterVariable('-right'  , vtCommand, @chRight_m      , false);
    RegisterVariable('+up'     , vtCommand, @chUp_p         , false);
    RegisterVariable('-up'     , vtCommand, @chUp_m         , false);
    RegisterVariable('+left'   , vtCommand, @chLeft_p       , false);
    RegisterVariable('-left'   , vtCommand, @chLeft_m       , false);
    RegisterVariable('+attack' , vtCommand, @chAttack_p     , false);
    RegisterVariable('+down'   , vtCommand, @chDown_p       , false);
    RegisterVariable('-down'   , vtCommand, @chDown_m       , false);
    RegisterVariable('hjump'   , vtCommand, @chHJump        , false);
    RegisterVariable('ljump'   , vtCommand, @chLJump        , false);
    RegisterVariable('nextturn', vtCommand, @chNextTurn     , false);
    RegisterVariable('-attack' , vtCommand, @chAttack_m     , false);
    RegisterVariable('slot'    , vtCommand, @chSlot         , false);
    RegisterVariable('setweap' , vtCommand, @chSetWeapon    , false);
//////// End top by freq analysis
    RegisterVariable('gencmd'  , vtCommand, @chGenCmd       , false);
    RegisterVariable('flag'    , vtCommand, @chFlag         , false);
    RegisterVariable('script'  , vtCommand, @chScript       , false);
    RegisterVariable('proto'   , vtCommand, @chCheckProto   , true );
    RegisterVariable('spectate', vtBoolean, @fastUntilLag   , false);
    RegisterVariable('capture' , vtCommand, @chCapture      , true );
    RegisterVariable('rotmask' , vtCommand, @chRotateMask   , true );
    RegisterVariable('rdriven' , vtCommand, @chTeamLocal    , false);
    RegisterVariable('map'     , vtCommand, @chSetMap       , false);
    RegisterVariable('theme'   , vtCommand, @chSetTheme     , false);
    RegisterVariable('seed'    , vtCommand, @chSetSeed      , false);
    RegisterVariable('template_filter', vtLongInt, @cTemplateFilter, false);
    RegisterVariable('mapgen'  , vtLongInt, @cMapGen        , false);
    RegisterVariable('maze_size',vtLongInt, @cMazeSize      , false);
    RegisterVariable('delay'   , vtLongInt, @cInactDelay    , false);
    RegisterVariable('ready'   , vtLongInt, @cReadyDelay    , false);
    RegisterVariable('casefreq', vtLongInt, @cCaseFactor    , false);
    RegisterVariable('healthprob', vtLongInt, @cHealthCaseProb, false);
    RegisterVariable('hcaseamount', vtLongInt, @cHealthCaseAmount, false);
    RegisterVariable('sd_turns', vtLongInt, @cSuddenDTurns  , false);
    RegisterVariable('waterrise', vtLongInt, @cWaterRise    , false);
    RegisterVariable('healthdec', vtLongInt, @cHealthDecrease, false);
    RegisterVariable('damagepct',vtLongInt, @cDamagePercent , false);
    RegisterVariable('ropepct' , vtLongInt, @cRopePercent   , false);
    RegisterVariable('minedudpct',vtLongInt,@cMineDudPercent, false);
    RegisterVariable('minesnum', vtLongInt, @cLandMines     , false);
    RegisterVariable('explosives',vtLongInt,@cExplosives    , false);
    RegisterVariable('gmflags' , vtLongInt, @GameFlags      , false);
    RegisterVariable('turntime', vtLongInt, @cHedgehogTurnTime, false);
    RegisterVariable('minestime',vtLongInt, @cMinesTime     , false);
    RegisterVariable('fort'    , vtCommand, @chFort         , false);
    RegisterVariable('grave'   , vtCommand, @chGrave        , false);
    RegisterVariable('hat'     , vtCommand, @chSetHat       , false);
    RegisterVariable('quit'    , vtCommand, @chQuit         , true );
    RegisterVariable('forcequit', vtCommand, @chForceQuit   , true );
    RegisterVariable('confirm' , vtCommand, @chConfirm      , true );
    RegisterVariable('halt',     vtCommand, @chHalt         , true );
    RegisterVariable('+speedup', vtCommand, @chSpeedup_p    , true );
    RegisterVariable('-speedup', vtCommand, @chSpeedup_m    , true );
    RegisterVariable('zoomin'  , vtCommand, @chZoomIn       , true );
    RegisterVariable('zoomout' , vtCommand, @chZoomOut      , true );
    RegisterVariable('zoomreset',vtCommand, @chZoomReset    , true );
    RegisterVariable('ammomenu', vtCommand, @chAmmoMenu     , true);
    RegisterVariable('+precise', vtCommand, @chPrecise_p    , false);
    RegisterVariable('-precise', vtCommand, @chPrecise_m    , false);
    RegisterVariable('switch'  , vtCommand, @chSwitch       , false);
    RegisterVariable('timer'   , vtCommand, @chTimer        , false);
    RegisterVariable('taunt'   , vtCommand, @chTaunt        , false);
    RegisterVariable('put'     , vtCommand, @chPut          , false);
    RegisterVariable('+volup'  , vtCommand, @chVol_p        , true );
    RegisterVariable('-volup'  , vtCommand, @chVol_m        , true );
    RegisterVariable('+voldown', vtCommand, @chVol_m        , true );
    RegisterVariable('-voldown', vtCommand, @chVol_p        , true );
    RegisterVariable('findhh'  , vtCommand, @chFindhh       , true );
    RegisterVariable('pause'   , vtCommand, @chPause        , true );
    RegisterVariable('+cur_u'  , vtCommand, @chCurU_p       , true );
    RegisterVariable('-cur_u'  , vtCommand, @chCurU_m       , true );
    RegisterVariable('+cur_d'  , vtCommand, @chCurD_p       , true );
    RegisterVariable('-cur_d'  , vtCommand, @chCurD_m       , true );
    RegisterVariable('+cur_l'  , vtCommand, @chCurL_p       , true );
    RegisterVariable('-cur_l'  , vtCommand, @chCurL_m       , true );
    RegisterVariable('+cur_r'  , vtCommand, @chCurR_p       , true );
    RegisterVariable('-cur_r'  , vtCommand, @chCurR_m       , true );
end;

procedure freeModule;
begin
end;

end.
