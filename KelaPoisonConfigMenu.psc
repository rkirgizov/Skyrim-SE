scriptname KelaPoisonConfigMenu extends SKI_ConfigBase
; SCRIPT VERSION ----------------------------------------------------------------------------------
;

; History
;
; 1 - Initial version

int function GetVersion()
	return 1 ; Default version
endFunction

Import KelaPoisonPluginScript 

Actor kPlayer
Perk Property ConcentratedPoison  Auto  

; Информация
String Property strPoisonCharges  Auto 
String Property strAvailableOptions  Auto  
String Property strPluginDesc  Auto
String Property strVersion  Auto  
String Property strProjectInfo  Auto  
String Property strAuthor  Auto  
String Property strTryButton  Auto  

; Настройки
String[] Property arrPoisonCharges  Auto  
String[] Property arrControlList  Auto 
String[] Property arrPoisonSystem  Auto 
String Property strWidgetsDisable  Auto 
String Property strControlCheck  Auto  
String Property strControlReverseMouse  Auto 
String Property strPoisonSystem  Auto   

; Сообщения
String Property strLuckyPoisoned  Auto  
String Property strUnLuckyPoisoned Auto
String Property strMediumLuckyPoisoned  Auto
String Property strLessLuckyPoisoned  Auto
String Property strLessUnLuckyPoisoned  Auto 

; Подсказки
String Property strHighlightAlchemy  Auto  
String Property strHighlightConcentratedP  Auto  
String Property strHighlightMarksman  Auto  
String Property strHighlightOneHanded  Auto  
String Property strHighlightTwoHanded  Auto  
String Property strHighlightWidjDis  Auto  
String Property strHighlightAuthor  Auto 
String Property strHighlightReverseM  Auto
String Property strHighlightLuck  Auto  
String Property strHighlightControlCheck  Auto  
String Property strHighlightPoisonSystem  Auto  

GlobalVariable Property kppPoisonSystemCheck Auto
GlobalVariable Property kppShowNotifications Auto
GlobalVariable Property kppControlCheck  Auto
GlobalVariable Property kppControlReverseMouse  Auto


; PRIVATE VARIABLES -------------------------------------------------------------------------------

; --- Version 1 ---

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int 	_text0OID_T		
int 	_toggle1OID_B	
int 	_text2OID_T		
int 	_text3OID_T
int	 	_text4OID_T		
int 	_text5OID_T	
int 	_text6OID_T	
int 	_toggle7OID_B
int		_controlListMenuOID_M
int 	_text8OID_T
int 	_toggle8OID_B	
int		_controlListMenu1OID_M

int 	iLuck
bool 	_toggleState7
bool 	_toggleState8			
int		_curControl	
int		_curSystem



; INITIALIZATION ----------------------------------------------------------------------------------
; @overrides SKI_ConfigBase
event OnConfigInit()
	If kppShowNotifications.GetValue() == 1
		_toggleState7 = True
	else	
		_toggleState7 = False
	endIf
	If kppControlReverseMouse.GetValue() == 1
		_toggleState8 = True
	else	
		_toggleState8 = False
	endIf
	If kppControlCheck.GetValue() == 0
		_curControl = 0
	elseIf kppControlCheck.GetValue() == 1	
		_curControl = 1
	elseIf kppControlCheck.GetValue() == 2	
		_curControl = 2
	endIf
	If kppPoisonSystemCheck.GetValue() == 0
		_curSystem = 0
	elseIf kppPoisonSystemCheck.GetValue() == 1	
		_curSystem = 1
	endIf
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
	{Called when a version update of this script has been detected}

	; Version 2 specific updating code
	; if (a_version >= 2 && CurrentVersion < 2)
		; Debug.Trace(self + ": Updating script to version 2")
		; _color = Utility.RandomInt(0x000000, 0xFFFFFF) ; Set a random color
	; endIf

	; Version 3 specific updating code
	; if (a_version >= 3 && CurrentVersion < 3)
		; Debug.Trace(self + ": Updating script to version 3")
		; _myKey = Input.GetMappedKey("Jump")
	; endIf
endEvent

event OnConfigOpen()

endEvent

; EVENTS ------------------------------------------------------------------------------------------


; @implements SKI_ConfigBase
event OnPageReset(string a_page)
	kPlayer = Game.GetPlayer()
	
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	AddHeaderOption(strPoisonCharges)

	_text0OID_T		= AddTextOption(arrPoisonCharges[0], GetChargesByAlchemy(), 1)
	_toggle1OID_B	= AddToggleOption(arrPoisonCharges[1], kPlayer.HasPerk(ConcentratedPoison), 1)
	_text2OID_T		= AddTextOption(arrPoisonCharges[2], GetChargesByPerkWeapon("OneHanded") as int, 1)
	_text3OID_T		= AddTextOption(arrPoisonCharges[3], GetChargesByPerkWeapon("TwoHanded") as int, 1)
	_text4OID_T		= AddTextOption(arrPoisonCharges[4], GetChargesByPerkWeapon("Marksman") as int, 1)
	_text5OID_T		= AddTextOption(arrPoisonCharges[5], strTryButton)
	
	SetCursorPosition(1)
	
	AddHeaderOption(strAvailableOptions)
	_controlListMenu1OID_M = AddMenuOption(strPoisonSystem, arrPoisonSystem[_curSystem])
	_toggle7OID_B	= AddToggleOption(strWidgetsDisable, _toggleState7)	
	_controlListMenuOID_M = AddMenuOption(strControlCheck, arrControlList[_curControl])
	_toggle8OID_B	= AddToggleOption(strControlReverseMouse, _toggleState8)	

	;AddEmptyOption()
	
	AddHeaderOption(strProjectInfo)
	_text6OID_T 	= AddTextOption(strVersion, "1.3")
	_text8OID_T		= AddTextOption(strAuthor, "")
endEvent


; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)
	{Called when the user selects a non-dialog option}
	
		if (a_option == _text0OID_T)

		elseIf (a_option == _toggle1OID_B) 

		elseIf (a_option == _text2OID_T)

		elseIf (a_option == _text3OID_T)
			
		elseIf (a_option == _text4OID_T)

		elseIf (a_option == _text5OID_T)
			iLuck = GetPlayerLuck ()
			If iLuck > 90
				ShowMessage(iLuck + " - " + strLuckyPoisoned, False)
			elseIf iLuck >= 70 && iLuck <= 90 
				ShowMessage(iLuck + " - " + strLessLuckyPoisoned, False)
			elseIf iLuck >= 10 && iLuck <= 30 
				ShowMessage(iLuck + " - " + strLessUnLuckyPoisoned, False)
			elseIf iLuck <= 10
				ShowMessage(iLuck + " - " + strUnLuckyPoisoned, False)
			else
				ShowMessage(iLuck + " - " + strMediumLuckyPoisoned, False)
			endIf
		elseIf (a_option == _text6OID_T)
		elseIf (a_option == _toggle7OID_B) 
			_toggleState7 = !_toggleState7
			SetToggleOptionValue(a_option, _toggleState7)
			If _toggleState7
				kppShowNotifications.SetValueInt(1)
			else
				kppShowNotifications.SetValueInt(0)
			endIf
		elseIf (a_option == _toggle8OID_B) 
			_toggleState8 = !_toggleState8
			SetToggleOptionValue(a_option, _toggleState8)
			If _toggleState8
				kppControlReverseMouse.SetValueInt(1)
			else
				kppControlReverseMouse.SetValueInt(0)
			endIf
		endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when the user selects a slider option}
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when the user accepts a new slider value}
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}
	If (a_option == _controlListMenuOID_M)
		SetMenuDialogStartIndex(_curControl)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(arrControlList)
	elseIf (a_option == _controlListMenu1OID_M)
		SetMenuDialogStartIndex(_curSystem)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(arrPoisonSystem)
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when the user accepts a new menu entry}
	If (a_option == _controlListMenuOID_M)	
		_curControl = a_index
		SetMenuOptionValue(a_option, arrControlList[_curControl])
		kppControlCheck.SetValueInt(_curControl)
	elseIf (a_option == _controlListMenu1OID_M)	
		_curSystem = a_index
		SetMenuOptionValue(a_option, arrPoisonSystem[_curSystem])
		kppPoisonSystemCheck.SetValueInt(_curSystem)
	endIf	
endEvent

; @implements SKI_ConfigBase
event OnOptionColorOpen(int a_option)
	{Called when a color option has been selected}
endEvent

; @implements SKI_ConfigBase
event OnOptionColorAccept(int a_option, int a_color)
	{Called when a new color has been accepted}
endEvent

; @implements SKI_ConfigBase
event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped}
endEvent

; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}
	if (a_option == _text0OID_T)
		SetInfoText(strHighlightAlchemy as String)
	elseIf (a_option == _toggle1OID_B)
		SetInfoText(strHighlightConcentratedP as String)
	elseIf (a_option == _text2OID_T)
		SetInfoText(strHighlightOneHanded as String)
	elseIf (a_option == _text3OID_T)
		SetInfoText(strHighlightTwoHanded as String)
	elseIf (a_option == _text4OID_T)
		SetInfoText(strHighlightMarksman as String)
	elseIf (a_option == _text5OID_T)
		SetInfoText(strHighlightLuck as String)
	elseIf (a_option == _text6OID_T)

	elseIf (a_option == _toggle7OID_B)
		SetInfoText(strHighlightWidjDis as String)
	elseIf (a_option == _controlListMenuOID_M)
		SetInfoText(strHighlightControlCheck as String)
	elseIf (a_option == _text8OID_T)
		SetInfoText(strHighlightAuthor as String)
	elseIf (a_option == _toggle8OID_B)
		SetInfoText(strHighlightReverseM as String)
	elseIf (a_option == _controlListMenu1OID_M)
		SetInfoText(strHighlightPoisonSystem as String)
	endIf
endEvent

int function GetChargesByAlchemy()
	int iChargesByAlchemy
	int iPlayerAlchemy = kPlayer.GetActorValue("Alchemy") as int
	If iPlayerAlchemy <= 10
		iChargesByAlchemy = 1
	elseIf iPlayerAlchemy > 10 && iPlayerAlchemy <= 20
		iChargesByAlchemy = 2
	elseIf iPlayerAlchemy > 20 && iPlayerAlchemy <= 30 
		iChargesByAlchemy = 3
	elseIf iPlayerAlchemy > 30 && iPlayerAlchemy <= 40 
		iChargesByAlchemy = 3
	elseIf iPlayerAlchemy > 40 && iPlayerAlchemy <= 50
		iChargesByAlchemy = 4
	elseIf iPlayerAlchemy > 50 && iPlayerAlchemy <= 60 
		iChargesByAlchemy = 4
	elseIf iPlayerAlchemy > 60 && iPlayerAlchemy <= 70 
		iChargesByAlchemy = 5
	elseIf iPlayerAlchemy > 70 && iPlayerAlchemy <= 80 
		iChargesByAlchemy = 5
	elseIf iPlayerAlchemy > 80 && iPlayerAlchemy <= 90 
		iChargesByAlchemy = 6
	elseIf iPlayerAlchemy > 90 && iPlayerAlchemy <= 10 
		iChargesByAlchemy = 6
	elseIf iPlayerAlchemy > 100
		iChargesByAlchemy = 7
	endIf
	return iChargesByAlchemy
endFunction

int function GetChargesByPerkWeapon(string sWeaponType)
	int ChargesByWeaponPerk
	int iPerkLevel = kPlayer.GetActorValue(sWeaponType) as int
	If iPerkLevel <= 20
		ChargesByWeaponPerk = 0
	elseIf iPerkLevel > 20 && iPerkLevel <= 40
		ChargesByWeaponPerk = 1
	elseIf iPerkLevel > 40 && iPerkLevel <= 60 
		ChargesByWeaponPerk = 2
	elseIf iPerkLevel > 60 && iPerkLevel <= 80 
		ChargesByWeaponPerk = 3
	elseIf iPerkLevel > 80 && iPerkLevel <= 100
		ChargesByWeaponPerk = 4
	elseIf iPerkLevel > 100
		ChargesByWeaponPerk = 5
	endIf
	return ChargesByWeaponPerk
endFunction

int function GetPlayerLuck ()
	iLuck = Utility.RandomInt(1, 100)
	return iLuck
endFunction