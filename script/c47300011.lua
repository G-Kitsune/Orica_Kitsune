--트랜캐스터 모스페트
local m=47300011
local cm=_G["c"..m]

function cm.initial_effect(c)
	aux.AddSquareProcedure(c)

	aux.AddSynchroMixProcedure(c,cm.pfil1,nil,nil,aux.NonTuner(nil),1,99,cm.pfun1)
	c:EnableReviveLimit()

	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)

	--special summon
	local e99=Effect.CreateEffect(c)
	e99:SetDescription(aux.Stringid(m,1))
	e99:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e99:SetCode(EVENT_LEAVE_FIELD)
	e99:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e99:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e99:SetCountLimit(1,m+1000)
	e99:SetCondition(cm.tcon)
	e99:SetTarget(cm.tg2)
	e99:SetOperation(cm.op2)
	c:RegisterEffect(e99)
	
end

cm.square_mana={0x0,0x0,0x0,0x0,0x0}
cm.custom_type=CUSTOMTYPE_SQUARE

function cm.pfil1(c)
	return c:IsSynchroType(TYPE_TUNER)
end
function cm.pfun1(g)
	local st=cm.square_mana
	return aux.IsFitSquare(g,st)
end

function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetManaCount(ATTRIBUTE_DARK)+c:GetManaCount(ATTRIBUTE_DIVINE)+c:GetManaCount(ATTRIBUTE_EARTH)+c:GetManaCount(ATTRIBUTE_FIRE)+c:GetManaCount(ATTRIBUTE_LIGHT)+c:GetManaCount(ATTRIBUTE_WATER)+c:GetManaCount(ATTRIBUTE_WIND)>0
end
function cm.filter(c)
	return c:IsSetCard(0xcce) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	if tc:IsAbleToHand() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end


function cm.tcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.tfilter2(c,e,tp)
	return c:IsSetCard(0xcce) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(3) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cm.tfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then
		return
	end
	local g=Duel.GetMatchingGroup(cm.tfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if g:GetCount()<1 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end