namespace Microsoft.SubscriptionBilling;

page 8054 "Contract Types"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Subscription Contract Type";
    Caption = 'Subscription Contract Types';
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the unique code of the Subscription Contract Type.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a brief description of the type of contract.';
                }
                field(HarmonizedBillingCustContracts; Rec.HarmonizedBillingCustContracts)
                {
                    ToolTip = 'Specifies that the contract elements of the Customer Subscription Contracts with this Subscription Contract Type are billed on a common key date.';
                }
#if not CLEAN27
                field(DefaultWithoutContractDeferrals; Rec."Def. Without Contr. Deferrals")
                {
                    ObsoleteReason = 'Removed in favor of Create Contract Deferrals.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.0';
                    Visible = false;
                    ToolTip = 'Specifies the default value for the associated field in the contract.';
                }
#endif
                field(ContractDeferrals; Rec."Create Contract Deferrals")
                {
                    ToolTip = 'Specifies the default value for the associated field in the contract.';
                }
                field(NoOfTranslationsCtrl; FieldTranslation.GetNumberOfTranslations(Rec, Rec.FieldNo(Description)))
                {
                    BlankZero = true;
                    Caption = 'No. of Translations';
                    ToolTip = 'Specifies the number of translations.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        FieldTranslation.OpenTranslationsForField(Rec, Rec.FieldNo(Description));
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenTranslation)
            {
                ApplicationArea = All;
                Caption = 'Translations';
                Image = Translate;
                ToolTip = 'Displays or edits translations. Translations are automatically considered and used according to the language code when printing.';

                trigger OnAction()
                begin
                    FieldTranslation.OpenTranslationsForField(Rec, Rec.FieldNo(Description));
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(OpenTranslation_Promoted; OpenTranslation)
                {
                }
            }
        }
    }

    var
        FieldTranslation: Record "Field Translation";
}