// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// ApexCharts
import ApexCharts from "apexcharts";

// Flowbite
import "flowbite/dist/flowbite.phoenix.js";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";

// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

// Flowbite datepicker
import Datepicker from "flowbite-datepicker/Datepicker";

import topbar from "../vendor/topbar";

const Hooks = {};
Hooks.DatePicker = {
  destroy() {
    this.datepicker.destroy()
  },
  mounted() {
    const datepickerEl = this.el;

    this.datepicker = new Datepicker(datepickerEl, {
      format: "yyyy-mm-dd",
    });

    datepickerEl.addEventListener("blur", (e) => {
      if (e.target.value) {
        datepickerEl.dispatchEvent(
          new Event("change", { bubbles: true, cancelable: true })
        );
      }
    });
  },
  destroyed() {
    this.destroy();
  }
};

Hooks.DateTimePicker = {
  destroy() {
    this.datepicker.destroy()
  },
  mounted() {
    const datePicekrEl = this.el.querySelector('[data-role="date-picker"');
    const timePicekrEl = this.el.querySelector('[data-role="time-picker"');

    this.datepicker = new Datepicker(datePicekrEl, {
      format: "yyyy-mm-dd",
    })

    datePicekrEl.addEventListener("blur", (e) => {
      this.updateValue(e.target.value, timePicekrEl.value);
    });

    timePicekrEl.addEventListener("input", (e) => {
      this.updateValue(datePicekrEl.value, e.target.value);
    });
  },
  updateValue(
    date, time
  ) {
    if (date && time) {
      const input = this.el.querySelector('[data-role="input"');
      input.value = `${date}T${time}`;
      input.dispatchEvent(
        new Event("change", { bubbles: true, cancelable: true })
      );
    }
  },
  destroyed() {
    this.destroy();
  }
}

Hooks.Chart = {
  getSeries() {
    return this.el.dataset.series ? JSON.parse(this.el.dataset.series) : []
  },
  destroy() {
    this.chart.destroy()
  },
  mounted() {
    const options = {
      chart: {
        height: "100%",
        maxWidth: "100%",
        fontFamily: "Inter, sans-serif",
        dropShadow: {
          enabled: false,
        },
        toolbar: {
          show: true,
          tools: {
            download: false,
            selection: true,
            zoom: true,
            zoomin: false,
            zoomout: false,
            pan: false,
            reset: true,
          },
        },
        zoom: {
          type: "x",
          enabled: true,
          autoScaleYaxis: true
        },
      },
      tooltip: {
        enabled: true,
        x: {
          show: true,
          formatter: (timestamp) => new Date(timestamp).toISOString()
        },
        y: {
          show: false
        }
      },
      dataLabels: {
        enabled: false,
      },
      grid: {
        show: true,
        strokeDashArray: 4,
        padding: {
          left: 2,
          right: 2,
          top: -26
        },
      },
      series: this.getSeries(),
      legend: {
        show: this.el.dataset.legendShow || false
      },
      stroke: {
        curve: "smooth"
      },
      zoom: {
        enabled: true
      },
      xaxis: {
        type: this.el.dataset.xAxisType || 'numeric',
        labels: {
          show: true,
          style: {
            fontFamily: "Inter, sans-serif",
            cssClass: "text-xs font-normal fill-gray-500 dark:fill-gray-400"
          }
        },
        axisBorder: {
          show: false,
        },
        axisTicks: {
          show: false,
        },
      },
      yaxis: {
        show: this.el.dataset.yAxisLabelsShow || false,
        labels: {
          formatter: (v) => {
            if (this.el.dataset.yAxisLabelsFormat) {
              return this.el.dataset.yAxisLabelsFormat.replace("(&1)", v);
            }

            return v;
          }
        }
      },
    };

    this.chart = new ApexCharts(this.el, options);
    this.chart.render();
  },
  updated() {
    this.destroy();
    this.mounted();
  },
  destroyed() {
    this.destroy();
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", _info => topbar.show(300));
window.addEventListener("phx:page-loading-stop", _info => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
