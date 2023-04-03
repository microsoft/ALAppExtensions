page 9260 "Customer Experience Survey"
{
    Extensible = false;
    Caption = ' ';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;

    layout
    {
        area(Content)
        {
            usercontrol(Survey; CustomerExperienceSurvey)
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    CurrPage.Survey.renderSurvey(SurveyDivLbl, SurveyId, TenantId, FormsProEligibilityId, Locale);
                end;
            }
        }
    }

    var
        SurveyId: Text;
        TenantId: Text;
        FormsProEligibilityId: Text;
        Locale: Text;
        SurveyDivLbl: Label 'surveyDiv', Locked = true;

    internal procedure SetSurveyProperties(NewSurveyId: Text; NewTenantId: Text; NewFormsProEligibilityId: Text; NewLocale: Text)
    begin
        SurveyId := NewSurveyId;
        TenantId := NewTenantId;
        FormsProEligibilityId := NewFormsProEligibilityId;
        Locale := NewLocale;
    end;
}