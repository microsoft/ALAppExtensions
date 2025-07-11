namespace Microsoft.Test.Sustainability;

page 148180 "Sust. Caption Class Test Page"
{
    PageType = Card;

    layout
    {
        area(Content)
        {
            field(NetChangeCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,1,1';
                ToolTip = 'Specifies the Net change in CO2 emissions.';
            }
            field(NetChangeCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,1,2';
                ToolTip = 'Specifies the Net change in CH4 emissions.';
            }
            field(NetChangeN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,1,3';
                ToolTip = 'Specifies the Net change in N2O emissions.';
            }
            field(BalanceAtDateCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,2,1';
                ToolTip = 'Specifies the balance of CO2 emissions at the specified date.';
            }
            field(BalanceAtDateCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,2,2';
                ToolTip = 'Specifies the balance of CH4 emissions at the specified date.';
            }
            field(BalanceAtDateN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,2,3';
                ToolTip = 'Specifies the balance of N2O emissions at the specified date.';
            }
            field(BalanceCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,3,1';
                ToolTip = 'Specifies the balance of CO2 emissions.';
            }
            field(BalanceCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,3,2';
                ToolTip = 'Specifies the balance of CH4 emissions.';
            }
            field(BalanceN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,3,3';
                ToolTip = 'Specifies the balance of N2O emissions.';
            }
            field(CO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,4,1';
                ToolTip = 'Specifies the CO2 emissions.';
            }
            field(CH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,4,2';
                ToolTip = 'Specifies the CH4 emissions.';
            }
            field(N2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,4,3';
                ToolTip = 'Specifies the N2O emissions.';
            }
            field(EmissionFactorCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,5,1';
                ToolTip = 'Specifies the emission factor for CO2.';
            }
            field(EmissionFactorCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,5,2';
                ToolTip = 'Specifies the emission factor for CH4.';
            }
            field(EmissionFactorN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,5,3';
                ToolTip = 'Specifies the emission factor for N2O.';
            }
            field(EmissionCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,6,1';
                ToolTip = 'Specifies the total CO2 emissions.';
            }
            field(EmissionCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,6,2';
                ToolTip = 'Specifies the total CH4 emissions.';
            }
            field(EmissionN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,6,3';
                ToolTip = 'Specifies the total N2O emissions.';
            }
            field(BaselineCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,7,1';
                ToolTip = 'Specifies the baseline CO2 emissions.';
            }
            field(BaselineCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,7,2';
                ToolTip = 'Specifies the baseline CH4 emissions.';
            }
            field(BaselineN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,7,3';
                ToolTip = 'Specifies the baseline N2O emissions.';
            }
            field(CurrentValueCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,8,1';
                ToolTip = 'Specifies the current value of CO2 emissions.';
            }
            field(CurrentValueCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,8,2';
                ToolTip = 'Specifies the current value of CH4 emissions.';
            }
            field(CurrentValueN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,8,3';
                ToolTip = 'Specifies the current value of N2O emissions.';
            }
            field(TargetValueCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,9,1';
                ToolTip = 'Specifies the target value for CO2 emissions.';
            }
            field(TargetValueCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,9,2';
                ToolTip = 'Specifies the target value for CH4 emissions.';
            }
            field(TargetValueN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,9,3';
                ToolTip = 'Specifies the target value for N2O emissions.';
            }
            field(DefaultEmissionCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,10,1';
                ToolTip = 'Specifies the default emission value for CO2.';
            }
            field(DefaultEmissionCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,10,2';
                ToolTip = 'Specifies the default emission value for CH4.';
            }
            field(DefaultEmissionN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,10,3';
                ToolTip = 'Specifies the default emission value for N2O.';
            }
            field(PostedEmissionCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,11,1';
                ToolTip = 'Specifies the posted emission value for CO2.';
            }
            field(PostedEmissionCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,11,2';
                ToolTip = 'Specifies the posted emission value for CH4.';
            }
            field(PostedEmissionN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,11,3';
                ToolTip = 'Specifies the posted emission value for N2O.';
            }
            field(TotalEmissionUnitOfMeasureCO2; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,12,1';
                ToolTip = 'Specifies the unit of measure for total CO2 emissions.';
            }
            field(TotalEmissionUnitOfMeasureCH4; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,12,2';
                ToolTip = 'Specifies the unit of measure for total CH4 emissions.';
            }
            field(TotalEmissionUnitOfMeasureN2O; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,12,3';
                ToolTip = 'Specifies the unit of measure for total N2O emissions.';
            }
            field(EnergyConsumption; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,13,4';
                ToolTip = 'Specifies the energy consumption in the specified unit of measure.';
            }
            field(PostedEnergyConsumption; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '102,14,4';
                ToolTip = 'Specifies the posted energy consumption in the specified unit of measure.';
            }
        }
    }

    var
        TextValue: Text[30];
}