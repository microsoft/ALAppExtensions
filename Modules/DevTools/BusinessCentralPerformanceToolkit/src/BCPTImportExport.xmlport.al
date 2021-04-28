xmlport 149001 "BCPT Import/Export"
{
    Caption = 'BCPT Import/Export';
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(BCPTSuite; "BCPT Header")
            {
                MaxOccurs = Unbounded;
                XmlName = 'BCPTSuite';
                fieldattribute(Code; BCPTSuite.Code)
                {
                    Occurrence = Required;
                }
                fieldattribute(Description; "BCPTSuite".Description)
                {
                    Occurrence = Optional;
                }
                fieldattribute(Tag; "BCPTSuite".Tag)
                {
                    Occurrence = Optional;
                }
                fieldattribute(Duration; "BCPTSuite"."Duration (minutes)")
                {
                    Occurrence = Optional;
                }
                fieldattribute(DefaultMinDelay; "BCPTSuite"."Default Min. User Delay (ms)")
                {
                    Occurrence = Optional;
                }
                fieldattribute(DefaultMaxDelay; "BCPTSuite"."Default Max. User Delay (ms)")
                {
                    Occurrence = Optional;
                }
                fieldattribute(WorkDateStarts; "BCPTSuite"."Work date starts at")
                {
                    Occurrence = Optional;
                }
                fieldattribute(DayCorrespondsTo; "BCPTSuite"."1 Day Corresponds to (minutes)")
                {
                    Occurrence = Optional;
                }
                tableelement(BCPTSuiteLine; "BCPT Line")
                {
                    LinkFields = "BCPT Code" = field("Code");
                    LinkTable = "BCPTSuite";
                    MinOccurs = Zero;
                    XmlName = 'Line';

                    fieldattribute(CodeunitID; BCPTSuiteLine."Codeunit ID")
                    {
                        Occurrence = Required;
                    }
                    fieldattribute(Parameters; BCPTSuiteLine.Parameters)
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(DelayBetwnItr; BCPTSuiteLine."Delay (sec. btwn. iter.)")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(DelayType; BCPTSuiteLine."Delay Type")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(Description; BCPTSuiteLine.Description)
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(MinDelay; BCPTSuiteLine."Min. User Delay (ms)")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(MaxDelay; BCPTSuiteLine."Max. User Delay (ms)")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(NoOfSessions; BCPTSuiteLine."No. of Sessions")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(RunInForeground; BCPTSuiteLine."Run in Foreground")
                    {
                        Occurrence = Optional;
                    }
                    trigger OnBeforeInsertRecord()
                    var
                        BCPTLine: Record "BCPT Line";
                    begin
                        BCPTLine.SetAscending("Line No.", true);
                        BCPTLine.SetRange("BCPT Code", BCPTSuite.Code);
                        if BCPTLine.FindLast() then;
                        BCPTSuiteLine."Line No." := BCPTLine."Line No." + 1000;
                    end;
                }
            }
        }
    }
    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }
}

