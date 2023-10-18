namespace Microsoft.API.FinancialManagement;

using Microsoft.Finance.GeneralLedger.Account;

page 30304 "API Finance - GL Account"
{
    PageType = API;
    EntityCaption = 'General Ledger Account';
    EntityName = 'generalLedgerAccount';
    EntitySetName = 'generalLedgerAccounts';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "G/L Account";
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemID)
                {
                    Caption = 'Id';
                }
                field(accountNumber; Rec."No.")
                {
                    Caption = 'Account Number';
                }
                field(accountName; Rec.Name)
                {
                    Caption = 'Account Name';
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account Type';
                }
                field(accountCategory; Rec."Account Category")
                {
                    Caption = 'Account Category';
                }
                field(accountSubcategoryEntryNumber; Rec."Account Subcategory Entry No.")
                {
                    Caption = 'Account Subcategory Entry Number';
                }
                field(accountSubcategoryDescription; Rec."Account Subcategory Descript.")
                {
                    Caption = 'Account Subcategory Description';
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation';
                }
                field(netChange; Rec."Net Change")
                {
                    Caption = 'Net Change';
                }
                field(incomeBalance; Rec."Income/Balance")
                {
                    Caption = 'Income Balance';
                }
                field(budgetFilter; Rec."Budget Filter")
                {
                    Caption = 'Budget Filter';
                }
                field(businessUnitFilter; Rec."Business Unit Filter")
                {
                    Caption = 'Business Unit Filter';
                }
                field(parentAccountNumber; ParentAccountNo)
                {
                    Caption = 'Parent Account Number';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last  Modified Date Time';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(ParentAccountNo);
        if ParentAccountDictionary.ContainsKey(Rec.Indentation - 1) then
            ParentAccountDictionary.Get(Rec.Indentation - 1, ParentAccountNo);

        if not ParentAccountDictionary.ContainsKey(Rec.Indentation) then
            ParentAccountDictionary.Add(Rec.Indentation, Rec."No.")
        else
            ParentAccountDictionary.Set(Rec.Indentation, Rec."No.");
    end;

    var
        ParentAccountNo: Code[20];
        ParentAccountDictionary: Dictionary of [Integer, Code[20]];
}
