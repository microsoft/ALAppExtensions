namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;

page 36961 "Account Categories"
{
    PageType = List;
    Caption = 'Power BI Account Categories';
    SourceTable = "Account Category";
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(AccountCategoryMapping)
            {
                field(PowerBIAccCategory; Rec."Account Category Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Power BI account category type.';
                    Width = 2;
                    Editable = false;
                }
                field(AccountCategoryDescription; AccountCategoryDesc)
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account Category';
                    ToolTip = 'Specifies the G/L Account Category that is mapped to this category type.';
                    Editable = AccountCategoryDescEditable;
                    Enabled = AccountCategoryDescEditable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GLAccountCategory: Record "G/L Account Category";
                        GLAccountCategories: Page "G/L Account Categories";
                    begin
                        GLAccountCategories.LookupMode(true);
                        if GLAccountCategories.RunModal() = Action::LookupOK then begin
                            GLAccountCategories.GetRecord(GLAccountCategory);

                            Rec."G/L Acc. Category Entry No." := GLAccountCategory."Entry No.";
                            Rec."Parent Acc. Category Entry No." := GLAccountCategory."Parent Entry No.";
                            AccountCategoryDesc := GLAccountCategory.Description;
                        end;
                    end;

                    trigger OnValidate()
                    var
                        GLAccountCategory: Record "G/L Account Category";
                        NoAccountCategoryMatchErr: Label 'There is no subcategory description that starts with ''%1''.', Comment = '%1 - the user input.';
                    begin
                        if AccountCategoryDesc = '' then
                            Rec."G/L Acc. Category Entry No." := 0
                        else begin
                            GLAccountCategory.SetFilter(Description, AccountCategoryDesc + '*');
                            if not GLAccountCategory.FindFirst() then
                                Error(NoAccountCategoryMatchErr, AccountCategoryDesc);
                            Rec."G/L Acc. Category Entry No." := GLAccountCategory."Entry No.";
                            Rec."Parent Acc. Category Entry No." := GLAccountCategory."Parent Entry No.";
                            AccountCategoryDesc := GLAccountCategory.Description;
                        end;
                    end;
                }
            }
        }
    }

    var
        AccountCategoryDesc: Text;
        AccountCategoryDescEditable: Boolean;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AccountCategoryDesc := '';
    end;

    trigger OnAfterGetRecord()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        AccountCategoryDesc := '';
        if GLAccountCategory.Get(Rec."G/L Acc. Category Entry No.") then
            AccountCategoryDesc := GLAccountCategory.Description;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        AccountCategoryDescEditable := CurrPage.Editable;
    end;
}