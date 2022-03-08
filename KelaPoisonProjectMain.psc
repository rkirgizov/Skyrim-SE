Scriptname KelaPoisonProjectMain extends ReferenceAlias
{main Kela Poison script}

Quest Property kQuest Auto  
Perk Property ConcentratedPoison Auto
Sound Property kppPoisonUse Auto
Sound Property kppPoisonRemove Auto
Potion Property kppPoisonCleanerRef Auto
Message Property kppPoisonRemoveMsg Auto
Message Property kppNotPoisonedMsg Auto
Message Property kppPluginActivatedMsg Auto
Message Property kppLuckyPoisonedMsg Auto
Message Property kppUnLuckyPoisonedMsg Auto
Message Property kppHandsNoWeaponMsg Auto
Message Property kppHandsNoWeaponPoisonRemoverMsg Auto
Message Property kppHandLeftNoWeaponMsg Auto
Message Property kppHandRightNoWeaponMsg Auto
Message Property kppPoisonIsEnd Auto


Actor kPlayer
Potion pUsedPotion
Weapon akWeaponR

int kppCount
string kPoisonType
int kPoisonCount
int kWeaponSlot		
int kppKeyDowned
int kppKeyDownedPrevious


GlobalVariable Property kppPoisonSystemCheck Auto
GlobalVariable Property kppShowNotifications Auto
GlobalVariable Property kppControlCheck  Auto
GlobalVariable Property kppControlReverseMouse  Auto

Import KelaPoisonPluginScript 
Import _Q2C_Functions



; Регистрируем удары/выстрелы, отлов событий меню и сообщений
Event OnInit ()
	;RegisterForMenu("MessageBoxMenu")
	RegisterForMenu("InventoryMenu")
	RegisterForMenu("FavoritesMenu")
 	RegisterForActorAction(0)
 	RegisterForActorAction(6) 
	kQuest.SetActive()
	kPlayer = Game.GetPlayer()
	kppPluginActivatedMsg.Show()
	kPlayer.AddItem(kppPoisonCleanerRef,3,True)
EndEvent

Event OnUpdate ()

EndEvent


;Для работы с Messagebox'ами
Event OnMenuOpen(String MenuName)
	If kppControlCheck.GetValueInt() == 0						; Стандарт
	elseIf kppControlCheck.GetValueInt() == 1					; Геймпад
		RegisterForKey (280)	; левый курок
		RegisterForKey (281)	; правый курок
		RegisterForKey (276)	; кнопка А
	elseIf kppControlCheck.GetValueInt() == 2					; Мышь
		RegisterForKey (18)		; Кнопка активации Е
		RegisterForKey (256)	; левая кнопка мыши
		RegisterForKey (257)	; правая кнопка мыши
	endIf
EndEvent

Event OnMenuClose(String MenuName)
	If kppControlCheck.GetValueInt() == 0						; Стандарт
	elseIf kppControlCheck.GetValueInt() == 1					; Геймпад
		UnRegisterForKey (280)	; левый курок
		UnRegisterForKey (281)	; правый курок
		UnRegisterForKey (276)	; кнопка А
	elseIf kppControlCheck.GetValueInt() == 2					; Мышь
		UnRegisterForKey (18)	; Кнопка активации (по умолчанию Е)
		UnRegisterForKey (256)	; левая кнопка мыши
		UnRegisterForKey (257)	; правая кнопка мыши
	endIf
EndEvent

Event OnKeyDown(Int KeyCode)
	string strKeyDown
	If kppControlCheck.GetValueInt() == 0						; Стандарт
	elseIf kppControlCheck.GetValueInt() == 1					; Геймпад
		If KeyCode == 280
			kppKeyDowned = 0
			;strKeyDown = "Left"
		elseIf KeyCode  == 281 || KeyCode  == 276
			kppKeyDowned = 1
			;strKeyDown = "Right or A"
		EndIf
	elseIf 	kppControlCheck.GetValueInt() == 2					; Мышь и клавиатура
		If kppControlReverseMouse.GetValueInt() == 0			; Установлен ли реерс кнопок мыши
			If KeyCode == 256 || KeyCode == 18						; левая кнопка мыши или Кнопка активации (по умолчанию Е)
				kppKeyDowned = 1
				;strKeyDown = "Left Mouse"
			elseIf KeyCode  == 257									; правая кнопка мыши
				kppKeyDowned = 0
				;strKeyDown = "Right Mouse"
			endIf
		elseIf kppControlReverseMouse.GetValueInt() == 1
			If KeyCode == 256 || KeyCode == 18						; левая кнопка мыши или Кнопка активации (по умолчанию Е)
				kppKeyDowned = 0
				;strKeyDown = "Left Mouse"
			elseIf KeyCode  == 257									; правая кнопка мыши
				kppKeyDowned = 1
				;strKeyDown = "Right Mouse"
			endIf
		endIf
	endIf	
	;Debug.Notification(strKeyDown)
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	;Debug.Notification("OnItemRemoved")
	int kppControlCheckStatus = kppControlCheck.GetValueInt()
	pUsedPotion = akBaseItem as Potion

	If kppKeyDownedPrevious != kppKeyDowned 
		kppKeyDownedPrevious = kppKeyDowned
		kppCount = 0
	endIf	
	
	If kPlayer.GetEquippedWeapon(True) || kPlayer.GetEquippedWeapon(False)
		If kppCount == 0
			kppCount = kppCount + 1				; Первый заход
		elseIf kppCount == 1
			kppCount = kppCount + 1				; Второй заход
		endIf
		If kppCount >= 2
			kppCount = 0
			return
		EndIf		
		If kppCount == 1
			If kppControlCheckStatus == 0						; Стандарт
				;Debug.Notification("Стандарт")
				akWeaponR = kPlayer.GetEquippedWeapon(False)
;				If !akWeaponR.IsStaff() && pUsedPotion.HasKeyword(Keyword.GetKeyword("VendorPoisonRemove"))
				If pUsedPotion == kppPoisonCleanerRef
					RemovePoisonFromWeapon(akWeaponR, pUsedPotion, 1)
				endIf					
				If IsReallyApplyPoisonToWeapon(akBaseItem, akItemReference, akDestContainer, False) && pUsedPotion != kppPoisonCleanerRef	
					ApplyPoisonOnWeapon (pUsedPotion, 1)
				endIf					
			elseIf kppControlCheckStatus == 1 || kppControlCheckStatus == 2				; Геймпад или Мышь
				If kppKeyDowned == 0 || kppKeyDowned == 1
					If kppKeyDowned == 1												; Правый курок или А или левая кнопка мыши
						;Debug.Notification("Правый курок или А")
						akWeaponR = kPlayer.GetEquippedWeapon(False)
						If pUsedPotion == kppPoisonCleanerRef
							RemovePoisonFromWeapon(akWeaponR, pUsedPotion, kppKeyDowned)
						endIf					
						If IsReallyApplyPoisonToWeapon(akBaseItem, akItemReference, akDestContainer, False) && pUsedPotion != kppPoisonCleanerRef	
							ApplyPoisonOnWeapon (pUsedPotion, kppKeyDowned)
						endIf					
					elseIf kppKeyDowned == 0											; Левый курок или правая кнопка мыши
						;Debug.Notification("Левый курок")
						akWeaponR = kPlayer.GetEquippedWeapon(True)
						If pUsedPotion == kppPoisonCleanerRef
							RemovePoisonFromWeapon(akWeaponR, pUsedPotion, kppKeyDowned)
						endIf					
						If IsReallyApplyPoisonToWeapon(akBaseItem, akItemReference, akDestContainer, True) && pUsedPotion != kppPoisonCleanerRef 	
							ApplyPoisonOnWeapon (pUsedPotion, kppKeyDowned)
						endIf
					endIf
				endIf
			endIf
		endIf
	else
		If kppCount == 0
			kppCount = kppCount + 1				; Первый заход
		elseIf kppCount == 1
			kppCount = kppCount + 1				; Второй заход
		endIf
		If kppCount >= 2
			kppCount = 0
			return
		EndIf		
		;kppHandsNoWeaponMsg.Show()
		If kppCount == 1
			If pUsedPotion == kppPoisonCleanerRef
				kppHandsNoWeaponPoisonRemoverMsg.Show()
				kPlayer.AddItem(pUsedPotion, 1, True)
				Utility.WaitMenuMode(0.4)
			endIf	
		endIf
	endIf
	

EndEvent	

; Берём оружие в руки
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  	If kppShowNotifications.GetValueInt() == 1
		If akBaseObject as Weapon && WornGetPoison(kPlayer, 0) && akBaseObject as Weapon == kPlayer.GetEquippedWeapon(True)
			kPoisonType = WornGetPoison(kPlayer, 0).GetName()
			kPoisonCount = WornGetPoisonCharges(kPlayer, 0)
			Debug.Notification(kPlayer.GetEquippedWeapon(True).GetName() + ", " + kPoisonType + " - " + kPoisonCount)
		elseIf akBaseObject as Weapon && WornGetPoison(kPlayer, 1) && akBaseObject as Weapon == kPlayer.GetEquippedWeapon(False)
			kPoisonType = WornGetPoison(kPlayer, 1).GetName()
			kPoisonCount = WornGetPoisonCharges(kPlayer, 1)
			Debug.Notification(kPlayer.GetEquippedWeapon(False).GetName() + ", " + kPoisonType + " - " + kPoisonCount)
		endIf
	endIf
EndEvent
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)

endEvent

; Отслеживаем удары
Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	If kppShowNotifications.GetValueInt() == 1	
		If akActor == kPlayer && IsWeaponPoisoned(slot)
			kPoisonType = WornGetPoison(kPlayer, slot).GetName()
			kPoisonCount = WornGetPoisonCharges(kPlayer, slot)
			If IsWeaponPoisoned (slot)
				Debug.Notification(kPoisonType + " - " + kPoisonCount)
			else
				kppPoisonIsEnd.Show()
			endIf
		endIf
	endIf
EndEvent

Function RemovePoisonFromWeapon(weapon wCleanedWeapon, potion UsedPotion, int slot)
	If (wCleanedWeapon && !wCleanedWeapon.IsStaff())	
		If !IsWeaponPoisoned(slot)
			kppNotPoisonedMsg.Show()
			Game.GetPlayer().AddItem(UsedPotion, 1, True)
			Utility.WaitMenuMode(0.4)
		else
			WornRemovePoison(kPlayer, slot)
			kppPoisonRemove.Play(kPlayer)
			kppPoisonUse.Play(kPlayer)
			kppPoisonRemoveMsg.Show()
		endIf
	elseIf wCleanedWeapon && wCleanedWeapon.IsStaff()
		kppHandsNoWeaponPoisonRemoverMsg.Show()
		kPlayer.AddItem(UsedPotion, 1, True)
		Utility.WaitMenuMode(0.4)		
	else
		If slot == 0
			kppHandLeftNoWeaponMsg.Show()
		else
			kppHandRightNoWeaponMsg.Show()
		endIf
		Game.GetPlayer().AddItem(UsedPotion, 1, True)
		Utility.WaitMenuMode(0.4)
	endIf
endFunction

Function ApplyPoisonOnWeapon (potion UsedPotion, int slot)
	If IsWeaponPoisoned(slot)		
		WornRemovePoison(kPlayer, slot)
		kPlayer.RemoveItem(UsedPotion, 1, True)
		WornSetPoison(kPlayer, slot, UsedPotion, GetMaxCharges())	
		kppPoisonUse.Play(kPlayer)
	else
		kPlayer.RemoveItem(UsedPotion, 1, True)
		WornSetPoison(kPlayer, slot, UsedPotion, GetMaxCharges())	
		kppPoisonUse.Play(kPlayer)		
	endIf	
endFunction

; Проверяем, отравлено ли оружие
bool Function IsWeaponPoisoned(int iSlot)
	If (WornGetPoison(kPlayer, iSlot))					
		return True
	endIf
endFunction 

; Проверяем, что применяется яд на оружие
bool Function IsReallyApplyPoisonToWeapon(Form akBaseItem, ObjectReference akItemReference, ObjectReference akDestContainer, bool bSlot)
	If !akDestContainer && !akItemReference && akBaseItem as Potion
		potion UsedPotion = akBaseItem as Potion
		If UsedPotion.IsPoison()
			akWeaponR = kPlayer.GetEquippedWeapon(bSlot) 					
			If (akWeaponR && !akWeaponR.IsStaff())
				return True
			else
				If bSlot
					kppHandLeftNoWeaponMsg.Show()
				else
					kppHandRightNoWeaponMsg.Show()
				endIf
				return False
				kppCount = 0
			endIf
		endIf
	endIf
endFunction

; Высчитываем максимальное количество зар¤дов для отравления
int Function GetMaxCharges ()
	int ChargesByWeaponPerk
	int MaxCharges
	int iPerkLevel
	int iPlayerAlchemy
	int iLuck
	int iPoisonSystemCheck
	iPoisonSystemCheck = kppPoisonSystemCheck.GetValueInt()
	If iPoisonSystemCheck == 0										; Система плагина Kela Poison Project
		; Высчитываем максимальное количество зарядов от Алхимии
		iPlayerAlchemy = kPlayer.GetActorValue("Alchemy") as int
		If iPlayerAlchemy <= 10
			MaxCharges = 1
		elseIf iPlayerAlchemy > 10 && iPlayerAlchemy <= 20
			MaxCharges = 2
		elseIf iPlayerAlchemy > 20 && iPlayerAlchemy <= 30 
			MaxCharges = 3
		elseIf iPlayerAlchemy > 30 && iPlayerAlchemy <= 40 
			MaxCharges = 3
		elseIf iPlayerAlchemy > 40 && iPlayerAlchemy <= 50
			MaxCharges = 4
		elseIf iPlayerAlchemy > 50 && iPlayerAlchemy <= 60 
			MaxCharges = 4
		elseIf iPlayerAlchemy > 60 && iPlayerAlchemy <= 70 
			MaxCharges = 5
		elseIf iPlayerAlchemy > 70 && iPlayerAlchemy <= 80 
			MaxCharges = 5
		elseIf iPlayerAlchemy > 80 && iPlayerAlchemy <= 90 
			MaxCharges = 6
		elseIf iPlayerAlchemy > 90 && iPlayerAlchemy <= 10 
			MaxCharges = 6
		elseIf iPlayerAlchemy > 100
			MaxCharges = 7
		endIf
		If (kPlayer.HasPerk(ConcentratedPoison))
			MaxCharges = MaxCharges * 2
		endIf
		; Высчитываем прибавку зарядов от владения типом оружия
		iPerkLevel = kPlayer.GetActorValue(GetPerkByWeapon(1)) as int	; уровень перка по оружию
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
		MaxCharges = MaxCharges + ChargesByWeaponPerk
		; Высчитываем удачу
		iLuck = Utility.RandomInt(1, 100)
		; Высчитываем итоговый заряд
		If iLuck > 90
			MaxCharges = (MaxCharges as float * Utility.RandomFloat(1.5, 2)) as int
			kppLuckyPoisonedMsg.Show ()
		elseIf iLuck >= 70 && iLuck <= 90 
			MaxCharges = (MaxCharges as float * Utility.RandomFloat(1, 1.5)) as int
		elseIf iLuck >= 10 && iLuck <= 30 
			MaxCharges = (MaxCharges as float * Utility.RandomFloat(0.5, 1)) as int
		elseIf iLuck <= 10
			MaxCharges = (MaxCharges as float * Utility.RandomFloat(0.1, 0.5)) as int
			kppUnLuckyPoisonedMsg.Show ()
		endIf
		If MaxCharges < 1
			MaxCharges = 1
		endIf
	elseIf iPoisonSystemCheck == 1									; Стандартная система игры
		MaxCharges = 1
		If (kPlayer.HasPerk(ConcentratedPoison))
			MaxCharges = MaxCharges * 2
		endIf
	endIf
	return MaxCharges
endFunction

string Function GetPerkByWeapon(int iHand)
	string sPerkByWeapon
	akWeaponR = kPlayer.GetEquippedWeapon()
	If akWeaponR.IsSword() || akWeaponR.IsDagger() || akWeaponR.IsWarAxe() || akWeaponR.IsMace() 	; это одноручное 
		sPerkByWeapon = "OneHanded"
	elseIf akWeaponR.IsGreatsword() || akWeaponR.IsBattleAxe() || akWeaponR.IsWarhammer() 			; это двуручное
		sPerkByWeapon = "TwoHanded"
	elseIf akWeaponR.IsBow()											 							; это стрелковое || akWeaponR.IsCrossbow()		
		sPerkByWeapon = "Marksman"
	else 
		sPerkByWeapon = "Unknown"
	endIf
	return sPerkByWeapon	
endFunction

string function GetHandName(int aiHand)
Debug.Notification("GetHandName")
	If (aiHand == 0)
		return "left"
	elseIf (aiHand == 1)
		return "right"
	endIf
	return "unknown"
endFunction



;------------------------------------------------------------------------------------------------------------

;****************************************** 
;int iNumR = Game.GetPlayer().GetEquippedItemType(1) ; что экипировано в правой руке 
;int iNumL = Game.GetPlayer().GetEquippedItemType(0) ; что экипировано в левой руке 
;0: Nothing (Hand to hand) 
;1: One-handed sword 
;2: One-handed dagger 
;3: One-handed axe 
;4: One-handed mace 
;5: Two-handed sword 
;6: Two-handed axe/mace 
;7: Bow 
;8: Staff 
;9: Magic spell 
;10: Shield 
;11: Torch 
;12: Crossbow 
;******************************************* 
;Weapon akWeaponR = Game.GetPlayer().GetEquippedWeapon() ; оружие в правой руке 
;Weapon akWeaponL = Game.GetPlayer().GetEquippedWeapon(true) ; оружие в левой руке 
;******************************************* 
;If akWeaponR == None ; оружи¤ в правой руке нет 
;elseIf akWeaponR.IsDagger() ; это кинжал 
;elseIf akWeaponR.IsBow() ; это лук 
;elseIf akWeaponR.IsSword() ; это меч 
;****************************************** 


;Function RegisterForActorAction(int actionType) native
;Function UnregisterForActorAction(int actionType) native

; ActionTypes
; 0 - Weapon Swing (Melee weapons that are swung, also barehand)
; 1 - Spell Cast (Spells and staves)
; 2 - Spell Fire (Spells and staves)
; 3 - Voice Cast
; 4 - Voice Fire
; 5 - Bow Draw
; 6 - Bow Release
; 7 - Unsheathe Begin
; 8 - Unsheathe End
; 9 - Sheathe Begin
; 10 - Sheathe End
; Slots
; 0 - Left Hand
; 1 - Right Hand
; 2 - Voice
;Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
;EndEvent

