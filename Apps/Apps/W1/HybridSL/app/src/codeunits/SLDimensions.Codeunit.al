// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

codeunit 47020 "SL Dimensions"
{
    Access = Internal;

    internal procedure GetSegmentNames()
    begin
        SLFlexDef.Reset();
        SLFlexDef.SetFilter(FieldClassName, 'SUBACCOUNT');
        if not SLFlexDef.FindFirst() then
            exit;

        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                MigratingCompanyList.Add(HybridCompany.Name);
            until HybridCompany.Next() = 0;

        SLSegmentName.DeleteAll();
        SegmentNbr := 0;
        repeat
            InsertSegmentName();
            SegmentNbr := SegmentNbr + 1;
        until SegmentNbr = SLFlexDef.NumberSegments;
    end;

    internal procedure InsertSegmentName()
    begin
        Clear(SLSegmentName);
        SLSegmentName."Segment Number" := SegmentNbr;
        SLSegmentName."Company Name" := CopyStr(MigratingCompanyList.Get(1), 1, MaxStrLen(SLSegmentName."Company Name"));
        case SegmentNbr of
            0:
                SLSegmentName."Segment Name" := SLFlexDef.Descr00;
            1:
                SLSegmentName."Segment Name" := SLFlexDef.Descr01;
            2:
                SLSegmentName."Segment Name" := SLFlexDef.Descr02;
            3:
                SLSegmentName."Segment Name" := SLFlexDef.Descr03;
            4:
                SLSegmentName."Segment Name" := SLFlexDef.Descr04;
            5:
                SLSegmentName."Segment Name" := SLFlexDef.Descr05;
            6:
                SLSegmentName."Segment Name" := SLFlexDef.Descr06;
            7:
                SLSegmentName."Segment Name" := SLFlexDef.Descr07;
        end;
        SLSegmentName.Insert();
    end;

    internal procedure InsertSLSegmentsForDimensionSets()
    var
        SLSegments: Record "SL Segments";
    begin

        SLFlexDef.Reset();
        SLFlexDef.SetFilter(FieldClassName, 'SUBACCOUNT');
        if not SLFlexDef.FindFirst() then
            exit;
        SegmentNbr := 0;
        SLSegments.DeleteAll();
        repeat
            case SegmentNbr of
                0:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr00) then
                            SLSegments.Id := SLFlexDef.Descr00.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr00;
                        SLSegments.Name := SLFlexDef.Descr00;
                        SLSegments.CodeCaption := SLFlexDef.Descr00.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr00.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                1:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr01) then
                            SLSegments.Id := SLFlexDef.Descr01.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr01;
                        SLSegments.Name := SLFlexDef.Descr01;
                        SLSegments.CodeCaption := SLFlexDef.Descr01.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr01.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                2:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr02) then
                            SLSegments.Id := SLFlexDef.Descr02.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr02;
                        SLSegments.Name := SLFlexDef.Descr02;
                        SLSegments.CodeCaption := SLFlexDef.Descr02.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr02.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                3:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr03) then
                            SLSegments.Id := SLFlexDef.Descr03.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr03;
                        SLSegments.Name := SLFlexDef.Descr03;
                        SLSegments.CodeCaption := SLFlexDef.Descr03.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr03.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                4:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr04) then
                            SLSegments.Id := SLFlexDef.Descr04.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr04;
                        SLSegments.Name := SLFlexDef.Descr04;
                        SLSegments.CodeCaption := SLFlexDef.Descr04.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr04.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                5:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr05) then
                            SLSegments.Id := SLFlexDef.Descr05.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr05;
                        SLSegments.Name := SLFlexDef.Descr05;
                        SLSegments.CodeCaption := SLFlexDef.Descr05.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr05.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                6:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr06) then
                            SLSegments.Id := SLFlexDef.Descr06.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr06;
                        SLSegments.Name := SLFlexDef.Descr06;
                        SLSegments.CodeCaption := SLFlexDef.Descr06.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr06.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
                7:
                    begin
                        if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr07) then
                            SLSegments.Id := SLFlexDef.Descr07.Trim() + 's'
                        else
                            SLSegments.Id := SLFlexDef.Descr07;
                        SLSegments.Name := SLFlexDef.Descr07;
                        SLSegments.CodeCaption := SLFlexDef.Descr07.Trim() + ' Code';
                        SLSegments.FilterCaption := SLFlexDef.Descr07.Trim() + ' Filter';
                        SLSegments.SegmentNumber := SegmentNbr + 1;
                        SLSegments.Insert();
                        Commit();
                    end;
            end;
            SegmentNbr += 1;
        until SegmentNbr = SLFlexDef.NumberSegments;
    end;

    internal procedure FlexDefDescInSLSubaccountSegDesc(flexDefDesc: Text[15]): Boolean
    begin
        case flexDefDesc.ToUpper().Trim() of
            'G/L ACCOUNT':
                exit(true);
            'BUSINESS UNIT':
                exit(true);
            'ITEM':
                exit(true);
            'LOCATION':
                exit(true);
            'PERIOD':
                exit(true);
            else
                exit(false);
        end;
    end;

    internal procedure CreateSLCodes()
    var
        SLSegdef: Record "SL SegDef";
        SLCodes: Record "SL Codes";
    begin
        SLFlexDef.Reset();
        SLFlexDef.SetFilter(FieldClassName, 'SUBACCOUNT');
        if not SLFlexDef.FindFirst() then
            exit;

        SLCodes.DeleteAll();
        SLSegdef.SetCurrentKey(SegNumber);
        SLSegdef.Ascending(true);
        SLSegdef.SetFilter(FieldClassName, 'SUBACCOUNT');
        if SLSegdef.FindSet() then
            repeat
                case SLSegdef.SegNumber.Trim() of
                    '1':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr00) then
                                SLCodes.Id := SLFlexDef.Descr00.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr00;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '2':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr01) then
                                SLCodes.Id := SLFlexDef.Descr01.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr01;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '3':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr02) then
                                SLCodes.Id := SLFlexDef.Descr02.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr02;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '4':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr03) then
                                SLCodes.Id := SLFlexDef.Descr03.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr03;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '5':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr04) then
                                SLCodes.Id := SLFlexDef.Descr04.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr04;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '6':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr05) then
                                SLCodes.Id := SLFlexDef.Descr05.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr05;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '7':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr06) then
                                SLCodes.Id := SLFlexDef.Descr06.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr06;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                    '8':
                        begin
                            if FlexDefDescInSLSubaccountSegDesc(SLFlexDef.Descr07) then
                                SLCodes.Id := SLFlexDef.Descr07.Trim() + 's'
                            else
                                SLCodes.Id := SLFlexDef.Descr07;
                            SLCodes.Name := SLSegdef.ID;
                            SLCodes.Description := SLSegdef.Description;
                            SLCodes.Insert();
                            Commit();
                        end;
                end;

            until SLSegdef.Next() = 0;
    end;

    var
        SLFlexDef: Record "SL FlexDef";
        SLSegmentName: Record "SL Segment Name";
        HybridCompany: Record "Hybrid Company";
        SegmentNbr: Integer;
        MigratingCompanyList: List of [Text];
}
