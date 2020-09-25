page 30001 "APIV2 - Aut. Companies"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Automation Company';
    EntitySetCaption = 'Automation Companies';
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
                    Caption = 'Id';
                    Editable = false;
                }
                field(name; Name)
                {
                    Caption = 'Name';
                    Editable = false;
                }
                field(evaluationCompany; "Evaluation Company")
                {
                    Caption = 'Evaluation Company';
                    Editable = false;
                }
                field(displayName; "Display Name")
                {
                    Caption = 'Display Name';
                    NotBlank = true;
                }
                field(businessProfileId; "Business Profile Id")
                {
                    Caption = 'Business ProfileId';
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
        "Evaluation Company" := false;
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

