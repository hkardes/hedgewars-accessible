/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2011 Vittorio Giovara <vittorio.giovara@gmail.com>
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * File created on 07/01/2010.
 */


#ifndef PASCALIMPORTS
#define PASCALIMPORTS

#ifdef __cplusplus
extern "C" {
#endif

    /* add C declarations below for all exported Pascal functions/procedure
     * that you want to use
     */

    void Game(const char *args[]);
    void GenLandPreview(void);
    void LoadLocaleWrapper(const char *filename);

    void HW_versionInfo(int *protoNum, char **versionStr);

    void HW_click(void);
    void HW_ammoMenu(void);
    
    void HW_zoomSet(float value);
    void HW_zoomIn(void);
    void HW_zoomOut(void);
    void HW_zoomReset(void);
    float HW_zoomFactor(void);
    int  HW_zoomLevel(void);

    void HW_walkingKeysUp(void);
    void HW_otherKeysUp(void);
    void HW_allKeysUp(void);

    void HW_walkLeft(void);
    void HW_walkRight(void);
    void HW_aimUp(void);
    void HW_aimDown(void);
    void HW_preciseSet(BOOL status);

    void HW_shoot(void);
    void HW_jump(void);
    void HW_backjump(void);

    void HW_chat(void);
    void HW_chatEnd(void);
    void HW_tab(void);
    void HW_screenshot(void);

    void HW_pause(void);
    void HW_pauseToggle(void);
    BOOL HW_isPaused(void);

    void *HW_getSDLWindow(void);
    void HW_terminate(BOOL andCloseFrontend);
    void HW_suspend(void);
    void HW_resume(void);

    void HW_setCursor(int x, int y);
    void HW_getCursor(int *x, int *y);

    BOOL HW_isAmmoMenuOpen(void);
    BOOL HW_isAmmoMenuNotAllowed(void);
    BOOL HW_isWeaponRequiringClick(void);
    BOOL HW_isWeaponTimerable(void);
    BOOL HW_isWeaponSwitch(void);
    BOOL HW_isWeaponRope(void);

    void HW_setGrenadeTime(int time);
    void HW_setPianoSound(int snd);
    
    void HW_setWeapon(int whichone);
    BOOL HW_isWeaponAnEffect(int whichone);
    char *HW_getWeaponNameByIndex(int whichone);
    char *HW_getWeaponCaptionByIndex(int whichone);
    char *HW_getWeaponDescriptionByIndex(int whichone);

    void HW_getAmmoDelays(unsigned char *pointer);
    int  HW_getAmmoCounts(int *pointer);
    
    int  HW_getNumberOfWeapons(void);
    int  HW_getTurnsForCurrentTeam(void);
    int  HW_getMaxNumberOfHogs(void);
    int  HW_getMaxNumberOfTeams(void);
    
#ifdef __cplusplus
}
#endif

#endif
