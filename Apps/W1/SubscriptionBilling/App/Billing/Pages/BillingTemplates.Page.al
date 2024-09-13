namespace Microsoft.SubscriptionBilling;

page 8066 "Billing Templates"
{
    Caption = 'Billing Templates';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Billing Template";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the unique code of the billing template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the name of the template.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Determines whether the template applies to customer or vendor contracts.';
                }
                field(HasContractFilterField; Rec.Filter.HasValue)
                {
                    Caption = 'Contract Filter';
                    ToolTip = 'Shows if the filters of the template are defined.';
                }
                field("Billing Date Formula"; Rec."Billing Date Formula")
                {
                    ToolTip = 'Specifies the formula for the date filter, which is used to filter billable service commitments ("Next Billing Date").';
                }
                field("Billing to Date Formula"; Rec."Billing to Date Formula")
                {
                    ToolTip = 'Specifies the optional formula for the date filter, for the maximum date up to which the service commitments are to be billed.';
                }
                field("My Suggestions Only"; Rec."My Suggestions Only")
                {
                    ToolTip = 'Specifies whether the service commitments which are to be billed are filtered only for myself.';
                }
                field("Group by"; Rec."Group by")
                {
                    ToolTip = 'Specifies the option for grouping contract billing lines.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CopyTemplate)
            {
                Caption = 'Copy Template';
                Image = Copy;
                Scope = Repeater;
                ToolTip = 'Copies the selected template.';

                trigger OnAction()
                var
                    BillingTemplate: Record "Billing Template";
                    NewCode: Code[20];
                begin
                    if Rec.Code = '' then
                        exit;

                    NewCode := Rec.Code;
                    IncreaseCode(NewCode);
                    while BillingTemplate.Get(NewCode) do
                        IncreaseCode(NewCode);
                    Rec.CalcFields(Filter);
                    BillingTemplate := Rec;
                    BillingTemplate.Code := NewCode;
                    BillingTemplate.Description := CopyStr(Rec.Description, 1, MaxStrLen(Rec.Description) - StrLen(CopyTxt)) + CopyTxt;
                    BillingTemplate.Insert(false);
                    Rec := BillingTemplate;
                end;
            }
            action(EditFilter)
            {
                Caption = 'Edit Filter';
                Image = EditAdjustments;
                Scope = Repeater;
                ToolTip = 'Edit filter of the selected billing template.';

                trigger OnAction()
                begin
                    Rec.EditFilter(Rec.FieldNo(Filter));
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CopyTemplate_Promoted; CopyTemplate)
                {
                }
                actionref(EditFilter_Promoted; EditFilter)
                {
                }
            }
        }
    }

    local procedure IncreaseCode(var NewCode: Code[20])
    var
        OldCode: Code[20];
    begin
        OldCode := NewCode;
        NewCode := IncStr(NewCode);
        if NewCode = '' then
            NewCode := CopyStr(OldCode, 1, MaxStrLen(NewCode) - 1) + '0';
    end;

    var
        CopyTxt: Label ' (Copy)';
}