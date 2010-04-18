function drawGraph(dataSeries) {

    function suffixFormatter(val, axis) {
        if (Math.abs(val) >= 1000000) {
            decimals = (( val % 1000000 ) == 0) ? 0 : axis.tickDecimals;
            return (val / 1000000).toFixed(decimals) + "M €";
        } else if (Math.abs(val) >= 1000) {
            decimals = (( val % 1000 ) == 0) ? 0 : axis.tickDecimals;
            return (val / 1000).toFixed(decimals) + "m €";
        } else
            decimals = (( val % 1 ) == 0) ? 0 : axis.tickDecimals;
        return val.toFixed(decimals);
    }
        
    function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            'background-color': '#fee',
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    }

    var previousPoint = null;
    $("#flot").bind("plothover", function (event, pos, item) {
        if (item) {
            if (previousPoint != item.datapoint) {
                previousPoint = item.datapoint;
                
                $("#tooltip").remove();
                var x = item.datapoint[0].toFixed(2),
                    amount = item.datapoint[1];
                
                showTooltip(item.pageX, item.pageY,
                            item.series.label + ": " + formatNumber(amount) + " €");
            }
        }
        else {
            $("#tooltip").remove();
            previousPoint = null;            
        }
    });
    
    $.plot($("#flot"), dataSeries, {
          xaxis: { mode: "time" },
          yaxis: { tickFormatter: suffixFormatter, labelWidth: 40 },
          series: {
              stack: true,
              bars: { show: true, barWidth: 2000000000 }
          },
          grid: { 
              hoverable: true, 
              clickable: true, 
              markings: [{ color: '#eee', yaxis: { to: 0 } }]
          }, 
          legend: { noColumns: 1, container: $("#flot-legend") },
          colors: ["#edc240", "#afd8f8", "#9440ed", "#4da74d", "#cb4b4b", "#555"]
        });
}