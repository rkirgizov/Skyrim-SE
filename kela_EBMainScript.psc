scriptName kela_EBMainScript extends ReferenceAlias
; kelamor (rkirgizov) Kela Experience Books
;-- Properties --------------------------------------
Actor property PlayerREF auto
Keyword Property VendorItemBook  Auto  
Keyword Property VendorItemRecipe  Auto  
Keyword Property VendorItemSpellTome  Auto  
Keyword Property VendorItemScroll  Auto  
Keyword Property GiftWizardSpecial  Auto  
Keyword Property GiftPriestSpecial  Auto  
Keyword Property GiftWarriorSpecial  Auto  
Keyword Property GiftThiefSpecial  Auto  
Keyword Property GiftBlacksmithSpecial  Auto  
Keyword Property GiftApothecarySpecial  Auto
FormList Property kela_BooksRead  Auto  
FormList Property kela_ScrollsUsed  Auto  
FormList[] Property kela_JustBooks  Auto 
FormList Property kela_JustRecipes  Auto  
Sound Property UISkillsGlow  Auto  
GlobalVariable Property kela_EBMultAddExp  Auto  
GlobalVariable Property kela_EBShowNotifications Auto
GlobalVariable Property kela_EBRecipesOn  Auto  
GlobalVariable Property kela_EBScrollsOn  Auto  
GlobalVariable Property kela_EBBooksOn  Auto  
GlobalVariable Property kela_EBSpellTomesOn  Auto 
GlobalVariable Property kela_EBReadTime  Auto  

; defined in the script
Book Property LastSelectedBook auto   
MagicEffect Property LastCastedMagicEffect  Auto  

;-- Variables ---------------------------------------
string BOOKMENU = "Book Menu"

function OnInit()
	RegisterForCrosshairRef()
	RegisterForMenu(BOOKMENU)	
 	RegisterForActorAction(1)
 	RegisterForActorAction(2) 	
endFunction

Event OnCrosshairRefChange(ObjectReference ref)
	if ref && (ref.HasKeyword(VendorItemBook) || ref.HasKeyword(VendorItemRecipe))
		if isJustBook (ref)
			LastSelectedBook = None
			LastSelectedBook = ref.GetBaseObject() as Book
			; Debug.Notification(ref.GetDisplayName() + " is a just book")
		endIf	
	elseIf !ref && LastSelectedBook != None
		LastSelectedBook = None
	endIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if akBaseObject as Book && (akBaseObject.HasKeyword(VendorItemBook) || akBaseObject.HasKeyword(VendorItemRecipe))
		if isJustBook (akBaseObject as ObjectReference)
			LastSelectedBook = None
			LastSelectedBook = akBaseObject as Book
		endIf
		if akBaseObject.HasKeyword(VendorItemSpellTome) && LastSelectedBook != None	&& kela_EBSpellTomesOn.GetValueInt() == 1
			TryIncreaseSkillByBook()
		endIf	
	endIf
endEvent

Event OnMenuOpen(String asMenuName)
	; debug.Notification("OnMenuOpen " + asMenuName)		
	if(asMenuName == BOOKMENU) && LastSelectedBook != None
		if !kela_BooksRead.HasForm(LastSelectedBook) 
			If (kela_JustRecipes.HasForm(LastSelectedBook) || LastSelectedBook.HasKeyword(VendorItemRecipe)) && kela_EBRecipesOn.GetValueInt() == 1
				TryIncreaseSkillByBook()
			elseIf LastSelectedBook.HasKeyword(VendorItemBook) && kela_EBBooksOn.GetValueInt() == 1
				
					
				
				float fltCount = 0
				float fltReadTime = kela_EBReadTime.GetValue()
				while UI.IsMenuOpen(BOOKMENU) && Utility.IsInMenuMode() && fltCount < fltReadTime

					Utility.WaitMenuMode(0.5)					
					fltCount += 0.5					
					; debug.Notification("IsMenuOpen BOOKMENU")

				
					if fltCount >= fltReadTime
						; debug.Notification("fltCount > fltReadTime")
						TryIncreaseSkillByBook()	
					else
						; debug.Notification("ELSE")
					endIf


					
				endWhile
				
				; debug.Notification("Exit While fltCount " + fltCount)


				
			endIf
		else
			Debug.Notification(LastSelectedBook.GetName() + " is already read")
		endIf			
	endIf
EndEvent

Event OnMenuClose(String asMenuName)
	if(asMenuName == BOOKMENU)
		; LastSelectedBook = None
		; debug.Notification("OnMenuClose " + asMenuName)		
	endIf
EndEvent

Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	If kela_EBScrollsOn.GetValueInt() == 1
		if actionType == 2 && source != None
			if !kela_ScrollsUsed.HasForm(source)
				scroll usedScroll = source as scroll
				int numEffects = usedScroll.GetNumEffects()
				int index = 0
				MagicEffect effect
				string effectSkill
				While index < numEffects
					effect = usedScroll.GetNthEffectMagicEffect(index)
					if effect != None
						LastCastedMagicEffect = None
						LastCastedMagicEffect = effect
						effectSkill = effect.GetAssociatedSkill()	
						float fltSkillPlayerLevel = PlayerREF.GetBaseActorValue(effectSkill)
						int needSkillLevel = effect.GetSkillLevel()
						if needSkillLevel > fltSkillPlayerLevel as int
							IncreaseThatSkillByMagicEffect(effectSkill)
						endIf
					endIf
					index += 1
				EndWhile
				kela_ScrollsUsed.AddForm(source)
			endIf
		endIf	
	endIf
EndEvent

;-- Functions ---------------------------------------
bool function isJustBook (ObjectReference refBook)
	if !refBook.HasKeyword(GiftWizardSpecial) && !refBook.HasKeyword(GiftPriestSpecial) && !refBook.HasKeyword(GiftWarriorSpecial) && !refBook.HasKeyword(GiftThiefSpecial) && !refBook.HasKeyword(GiftBlacksmithSpecial) && !refBook.HasKeyword(GiftApothecarySpecial)
		return True
	endIf
	return False
endFunction

function IncreaseThatSkillByMagicEffect (string strSkill)
	float fltSkillPlayerLevel = PlayerREF.GetBaseActorValue(strSkill)
	ActorValueInfo aVI = ActorValueInfo.GetActorValueInfobyName(strSkill)
	float needExpOnLevel = aVI.GetExperienceForLevel(fltSkillPlayerLevel as int)
	float currentExpLevel = aVI.GetSkillExperience()
	float addExp = needExpOnLevel * kela_EBMultAddExp.GetValue()	
	float magicEffectCost = LastCastedMagicEffect.GetBaseCost() as float	
	if magicEffectCost > 100
		addExp += addExp
	elseIf magicEffectCost > 0 
		addExp += addExp*(magicEffectCost/100)
	endIf	
	float newExp = currentExpLevel + addExp 
	float expOffset = newExp - needExpOnLevel
	if expOffset < 0
		aVI.SetSkillExperience(newExp)
	else
		Game.IncrementSkill(strSkill)
		aVI.SetSkillExperience(expOffset)
	endIf
	If kela_EBShowNotifications.GetValueInt() == 1
		debug.Notification(strSkill + ": Experience gained " + newExp)	
	endIf
	UISkillsGlow.play(PlayerREF)
endFunction

function IncreaseThatSkillByBook (string strSkill, float multBySkill)
	float fltSkillPlayerLevel = PlayerREF.GetBaseActorValue(strSkill)
	ActorValueInfo aVI = ActorValueInfo.GetActorValueInfobyName(strSkill)
	float needExpOnLevel = aVI.GetExperienceForLevel(fltSkillPlayerLevel as int)
	float currentExpLevel = aVI.GetSkillExperience()
	float addExp = needExpOnLevel * kela_EBMultAddExp.GetValue() * multBySkill
	float bookValue = LastSelectedBook.GetGoldValue() as float	
	if kela_JustRecipes.HasForm(LastSelectedBook) || LastSelectedBook.HasKeyword(VendorItemRecipe)
		addExp = addExp*0.5
	endIf	
	if bookValue > 100 && LastSelectedBook.HasKeyword(VendorItemSpellTome)
		addExp += addExp
	elseIf bookValue > 0 
		addExp += addExp*(bookValue/100)
	endIf	
	float newExp = currentExpLevel + addExp 
	float expOffset = newExp - needExpOnLevel
	if expOffset < 0
		aVI.SetSkillExperience(newExp)
	else
		Game.IncrementSkill(strSkill)
		aVI.SetSkillExperience(expOffset)
	endIf
  	If kela_EBShowNotifications.GetValueInt() == 1
		debug.Notification(strSkill + ": Experience gained " + newExp)	
	endIf
	UISkillsGlow.play(PlayerREF)
endFunction

function TryIncreaseSkillByBook()
	; if !kela_BooksRead.HasForm(LastSelectedBook) 
		; Debug.Notification(LastSelectedBook.GetName() + " TryIncreaseSkillByBook")
		if kela_JustBooks[0].HasForm(LastSelectedBook) 
			IncreaseThatSkillByBook ("Alchemy", 1.0)
		endIf
		if kela_JustBooks[1].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Alteration", 1.0)
		endIf
		if kela_JustBooks[2].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Block", 1.0)
		endIf
		if kela_JustBooks[3].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Conjuration", 1.0)
		endIf
		if kela_JustBooks[4].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Destruction", 1.0)
		endIf
		if kela_JustBooks[5].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Enchanting", 1.0)
		endIf
		if kela_JustBooks[6].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("HeavyArmor", 1.0)
		endIf
		if kela_JustBooks[7].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Illusion", 1.0)
		endIf
		if kela_JustBooks[8].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("LightArmor", 1.0)
		endIf
		if kela_JustBooks[9].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Lockpicking", 1.0)
		endIf
		if kela_JustBooks[10].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Marksman", 1.0)
		endIf
		if kela_JustBooks[11].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("OneHanded", 1.0)
		endIf
		if kela_JustBooks[12].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Pickpocket", 1.0)
		endIf
		if kela_JustBooks[13].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Restoration", 1.0)
		endIf
		if kela_JustBooks[14].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Smithing", 1.0)
		endIf
		if kela_JustBooks[15].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Sneak", 1.0)
		endIf
		if kela_JustBooks[16].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("Speechcraft", 0.5)
		endIf
		if kela_JustBooks[17].HasForm(LastSelectedBook)  
			IncreaseThatSkillByBook ("TwoHanded", 1.0)
		endIf		
		kela_BooksRead.AddForm(LastSelectedBook)
		LastSelectedBook = None
	; else
		; Debug.Notification(LastSelectedBook.GetName() + " is already read")
	; endIf	
endfunction