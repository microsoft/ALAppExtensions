var template = `
<div class="container">
    <div id="attributes" class="hidden">
        <table class="table">
            <tbody id="attributes-tbody"></tbody>
        </table>
    </div>

    <div id="components"  class="hidden">
        <table class="table">
            <thead>
                <tr>
                    <th>Component</th>
                    <th class="decimal-column">Percent</th>
                    <th class="decimal-column">Amount</th>
                </tr>
            </thead>
            <tbody id="components-tbody"></tbody>
        </table>
    </div>
    
    <div id="nothing-to-show" class="blank-line">
        <p>Nothing to show</p>
    </div>
</div>`;

document.getElementById("controlAddIn").innerHTML = template;
window.__TaxInfoLoaded = true;
if (window.__TaxInfoData) {
    renderData(window.__TaxInfoData.attributes, window.__TaxInfoData.components);
    window.__TaxInfoData = undefined;
}
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AddInLoaded');
