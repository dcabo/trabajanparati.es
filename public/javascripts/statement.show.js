function drawGraph(dataSeries, statementsIds) {

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
        $('<div id="tooltip">'+contents+'</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            'background-color': '#fee',
            opacity: 0.80
        }).appendTo("body").fadeIn(100);
    }

    // TODO: Don't look, don't look, it's so ugly...
    // Hack together a call-back to retrieve more detailed data when hovering the graph
    var itemTypes = ['P', 'C', 'F', 'V', 'L', 'N'];
    
    var previousDataIndex = null;
    var previousSeriesIndex = null;
    $("#flot").bind("plothover", function (event, pos, item) {
        if (item) {
            if ((previousDataIndex != item.dataIndex) || (previousSeriesIndex != item.seriesIndex)) {
                previousDataIndex = item.dataIndex;
                previousSeriesIndex = item.seriesIndex;
                
                $("#tooltip").remove();
                var x = item.datapoint[0].toFixed(2),
                    amount = item.datapoint[1];
                
                // Warning: hardcoded URL 
                $.get('/statements/'+statementsIds[item.dataIndex]+'/'+itemTypes[item.seriesIndex], function(data) {
                    showTooltip(item.pageX, item.pageY, data);
                });
            }
        }
        else {
            $("#tooltip").remove();
            previousDataIndex = null;
            previousSeriesIndex = null;
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