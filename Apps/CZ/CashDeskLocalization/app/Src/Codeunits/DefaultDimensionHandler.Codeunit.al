// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Dimension;

codeunit 31084 "Default Dimension Handler CZP"
{
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterUpdateGlobalDimCode', '', false, false)]
    local procedure OnAfterUpdateGlobalDimCode(TableID: Integer; GlobalDimCodeNo: Integer; AccNo: Code[20]; NewDimValue: Code[20])
    begin
        case TableID of
            Database::"Cash Desk CZP":
                UpdateCashDeskCZPGlobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
            Database::"Cash Desk Event CZP":
                UpdateCashDeskEventCZPGlobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
        end;
    end;

    local procedure UpdateCashDeskCZPGlobalDimCode(GlobalDimCodeNo: Integer; CashDeskNo: Code[20]; NewDimValue: Code[20])
    var
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if CashDeskCZP.Get(CashDeskNo) then begin
            case GlobalDimCodeNo of
                1:
                    CashDeskCZP."Global Dimension 1 Code" := NewDimValue;
                2:
                    CashDeskCZP."Global Dimension 2 Code" := NewDimValue;
            end;
            CashDeskCZP.Modify(true);
        end;
    end;

    local procedure UpdateCashDeskEventCZPGlobalDimCode(GlobalDimCodeNo: Integer; CashDeskEventNo: Code[20]; NewDimValue: Code[20])
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
    begin
        if CashDeskEventCZP.Get(CashDeskEventNo) then begin
            case GlobalDimCodeNo of
                1:
                    CashDeskEventCZP."Global Dimension 1 Code" := NewDimValue;
                2:
                    CashDeskEventCZP."Global Dimension 2 Code" := NewDimValue;
            end;
            CashDeskEventCZP.Modify(true);
        end;
    end;
}
