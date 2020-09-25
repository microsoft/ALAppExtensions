page 20001 "APIV1 - Aut. Companies"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'automationCompany', Locked = true;
    DelayedInsert = true;
    EntityName = 'automationCompany';
    EntitySetName = 'automationCompanies';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = Company;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(name; Name)
                {
                    Caption = 'name', Locked = true;
                    Editable = false;
                }
                field(evaluationCompany; "Evaluation Company")
                {
                    Caption = 'evaluationCompany', Locked = true;
                    Editable = false;
                }
                field(displayName; "Display Name")
                {
                    Caption = 'displayName', Locked = true;
                    NotBlank = true;
                }
                field(businessProfileId; "Business Profile Id")
                {
                    Caption = 'businessProfileId', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Name := COPYSTR("Display Name", 1, MAXSTRLEN(Name));
        "Evaluation Company" := FALSE;
    end;

    trigger OnOpenPage()
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

