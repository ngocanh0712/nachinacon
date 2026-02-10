import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { records: Array }
  static targets = ["heightCanvas", "weightCanvas"]

  async connect() {
    const mod = await import("chart.js")
    // UMD build: Chart is the default export or a property, or a global
    const Chart = mod.default || mod.Chart || window.Chart
    if (Chart.registerables) {
      Chart.register(...Chart.registerables)
    }
    this.Chart = Chart

    if (this.recordsValue.length > 0) {
      this._renderCharts()
    }
  }

  _renderCharts() {
    const records = this.recordsValue
    const labels = records.map(r => `${r.age_months}th`)

    // WHO P50 reference data for boys 0-36 months
    const whoMonths = [0,1,2,3,4,5,6,7,8,9,10,11,12,15,18,21,24,30,36]
    const whoHeight = [49.9,54.7,58.4,61.4,63.9,65.9,67.6,69.2,70.6,72.0,73.3,74.5,75.7,79.1,82.3,85.1,87.8,92.4,96.1]
    const whoWeight = [3.3,4.5,5.6,6.4,7.0,7.5,7.9,8.3,8.6,8.9,9.2,9.4,9.6,10.3,10.9,11.5,12.2,13.3,14.3]
    if (this.hasHeightCanvasTarget) {
      this._createChart(this.heightCanvasTarget, 'Chiều cao (cm)', labels,
        records.map(r => r.height_cm).filter(v => v),
        '#C1DDD8', whoMonths, whoHeight, 'WHO P50')
    }

    if (this.hasWeightCanvasTarget) {
      this._createChart(this.weightCanvasTarget, 'Cân nặng (kg)', labels,
        records.map(r => r.weight_kg).filter(v => v),
        '#F2C2C2', whoMonths, whoWeight, 'WHO P50')
    }
  }

  _createChart(canvas, title, labels, data, color, whoMonths, whoData, whoLabel) {
    if (data.length === 0) {
      canvas.parentElement.style.display = 'none'
      return
    }

    const records = this.recordsValue
    const dataMonths = records.map(r => r.age_months)

    // Interpolate WHO data to match baby's months
    const whoInterpolated = dataMonths.map(m => {
      const idx = whoMonths.findIndex(wm => wm >= m)
      if (idx === 0) return whoData[0]
      if (idx === -1) return whoData[whoData.length - 1]
      const prev = whoMonths[idx - 1], next = whoMonths[idx]
      const ratio = (m - prev) / (next - prev)
      return whoData[idx - 1] + ratio * (whoData[idx] - whoData[idx - 1])
    })

    new this.Chart(canvas, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: title,
            data: data,
            borderColor: color,
            backgroundColor: color + '30',
            borderWidth: 3,
            pointRadius: 5,
            pointBackgroundColor: color,
            fill: true,
            tension: 0.3
          },
          {
            label: whoLabel,
            data: whoInterpolated,
            borderColor: '#9CA3AF',
            borderWidth: 2,
            borderDash: [5, 5],
            pointRadius: 0,
            fill: false,
            tension: 0.3
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: window.innerWidth >= 1024 ? 1.4 : 1.6,
        plugins: {
          legend: {
            position: 'top',
            labels: { font: { family: 'Poppins', weight: '600', size: 11 }, boxWidth: 12, padding: 12 }
          }
        },
        scales: {
          x: {
            title: { display: true, text: 'Tháng tuổi', font: { family: 'Poppins', size: 11 } },
            grid: { display: false },
            ticks: { font: { size: 10 } }
          },
          y: {
            title: { display: true, text: title, font: { family: 'Poppins', size: 11 } },
            grid: { color: '#f3f4f6' },
            ticks: { font: { size: 10 } }
          }
        }
      }
    })
  }
}
