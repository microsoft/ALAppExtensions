pageextension 5282 "Dimensions SAF-T" extends Dimensions
{
    layout
    {
        addlast(Control1)
        {
            field(AnalysisTypeSAFT; Rec."Analysis Type SAF-T")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the SAF-T code that will be exported to AnalysisType XML node of the SAF-T file.';
            }
            field(ExportToSAFT; Rec."SAF-T Export")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if information about this dimension will be exported to the SAF-T file.';
            }
        }
    }
}