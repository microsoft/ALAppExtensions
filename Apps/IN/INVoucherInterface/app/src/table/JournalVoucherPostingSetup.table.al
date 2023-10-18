// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;

table 18930 "Journal Voucher Posting Setup"
{
    Caption = 'Voucher Posting Setup';
    DataClassification = EndUserIdentifiableInformation;

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Location;
        }
        field(2; Type; Enum "Gen. Journal Template Type")
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if Type in [Type::General, Type::Intercompany, Type::Jobs, Type::Payments, Type::Purchases, Type::Sales, Type::Assets] then
                    Error(TypeErr, Type, "Location Code");
            end;
        }
        field(3; "Posting No. Series"; Code[10])
        {
            TableRelation = "No. Series".Code;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Transaction Direction"; Option)
        {
            OptionCaption = ' ,Debit,Credit,Both';
            OptionMembers = " ",Debit,Credit,Both;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if ("Transaction Direction" <> "Transaction Direction"::" ") and (xRec."Transaction Direction" <> "Transaction Direction") then
                    case Xrec."Transaction Direction" of
                        xRec."Transaction Direction"::Credit:
                            ValidationEvents.DeleteCrAccounts("Location Code", Type);
                        xRec."Transaction Direction"::Debit:
                            ValidationEvents.DeleteDrAccounts("Location Code", Type);
                        else begin
                            ValidationEvents.DeleteCrAccounts("Location Code", Type);
                            ValidationEvents.DeleteDrAccounts("Location Code", Type);
                        end;
                    end;
            end;
        }
    }

    keys
    {
        key(Key1; "Location Code", "Type")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        ValidationEvents.DeleteCrAccounts("Location Code", Type);
        ValidationEvents.DeleteDrAccounts("Location Code", Type);
    end;

    trigger OnInsert()
    begin
        TestField("Type");
    end;

    var
        ValidationEvents: Codeunit "Validation Events";
        TypeErr: Label 'Type must not be %1 in Voucher Posting Setup: Location Code: %2, Type : %1', Comment = ' %1= Gen. Journal Template Type %2 = Location Code';
}
