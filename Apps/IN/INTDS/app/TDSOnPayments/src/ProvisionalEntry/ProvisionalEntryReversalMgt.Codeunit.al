// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

codeunit 18772 "Provisional Entry Reversal Mgt"
{
    SingleInstance = true;
    Access = Internal;
    procedure SetReverseProvEntWithoutTDS(ReverseProvEntWOTDS: Boolean)
    begin
        ReverseProvEntWithoutTDS := ReverseProvEntWOTDS;
    end;

    procedure GetReverseProvEntWithoutTDS(): Boolean
    begin
        exit(ReverseProvEntWithoutTDS);
    end;

    var
        ReverseProvEntWithoutTDS: Boolean;
}
