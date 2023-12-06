// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

tableextension 11750 "Acc. Schedule Name CZL" extends "Acc. Schedule Name"
{
    fields
    {
        field(31070; "Acc. Schedule Type CZL"; Enum "Accounting Schedule Type CZL")
        {
            Caption = 'Accounting Schedule Type';
            DataClassification = CustomerContent;
        }
    }

    procedure IsResultsExistCZL(AccSchedName: Code[10]): Boolean
    var
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
    begin
        AccScheduleResultHdrCZL.SetRange("Acc. Schedule Name", AccSchedName);
        exit(not AccScheduleResultHdrCZL.IsEmpty());
    end;

    procedure GetRecordDescriptionCZL(AccSchedName: Code[10]): Text[100]
    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleDefTok: Label '%1 %2=''%3''', Locked = true;
    begin
        AccScheduleName.Get(AccSchedName);
        exit(StrSubstNo(AccScheduleDefTok, AccScheduleName.TableCaption, Rec.FieldCaption(Name), AccSchedName));
    end;
}
