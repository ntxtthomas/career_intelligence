module DashboardHelper
  def pie_chart_svg(data, size: 200, colors: nil)
    # data should be a hash of {label => value} or array of {name, value}
    values = data.is_a?(Hash) ? data.values : data.map { |d| d[:value] || d[:count] }
    total = values.sum.to_f

    # Enhanced color palette with yellow, green, and light blue for better contrast
    default_colors = [ "#6366f1", "#22c55e", "#eab308", "#60a5fa", "#f43f5e", "#ec4899", "#f97316" ]
    colors ||= default_colors

    svg_data = []
    current_angle = -90

    data_array = data.is_a?(Hash) ? data.to_a : data

    data_array.each_with_index do |item, index|
      label = data.is_a?(Hash) ? item[0] : item[:name]
      value = data.is_a?(Hash) ? item[1] : (item[:value] || item[:count])
      percentage = (value.to_f / total * 100).round(1)

      # Calculate angle
      angle = percentage * 3.6
      start_angle = current_angle
      end_angle = current_angle + angle

      # Convert to radians
      start_rad = (start_angle * Math::PI / 180)
      end_rad = (end_angle * Math::PI / 180)

      # Calculate coordinates
      radius = size / 2 - 10
      cx = size / 2
      cy = size / 2

      x1 = cx + radius * Math.cos(start_rad)
      y1 = cy + radius * Math.sin(start_rad)
      x2 = cx + radius * Math.cos(end_rad)
      y2 = cy + radius * Math.sin(end_rad)

      large_arc = angle > 180 ? 1 : 0

      color = colors[index % colors.length]

      # SVG path for pie slice
      path_data = "M #{cx},#{cy} L #{x1},#{y1} A #{radius},#{radius} 0 #{large_arc},1 #{x2},#{y2} Z"
      svg_data << {
        path: path_data,
        color: color,
        label: label,
        value: value,
        percentage: percentage
      }

      current_angle = end_angle
    end

    # Generate SVG
    svg = "<svg width='#{size}' height='#{size}' viewBox='0 0 #{size} #{size}' style='display: inline-block;'>"
    svg_data.each do |slice|
      svg += "<path d='#{slice[:path]}' fill='#{slice[:color]}' />"
    end
    svg += "</svg>"

    # Return SVG and legend
    legend_html = "<div style='margin-left: 15px; text-align: left;'>"
    svg_data.each do |slice|
      legend_html += "<div style='margin-bottom: 8px; font-size: 13px;'>"
      legend_html += "<span style='display: inline-block; width: 12px; height: 12px; background-color: #{slice[:color]}; margin-right: 6px; border-radius: 2px;'></span>"
      legend_html += "<strong>#{ERB::Util.html_escape(slice[:label])}</strong>: #{slice[:value]} (#{slice[:percentage]}%)"
      legend_html += "</div>"
    end
    legend_html += "</div>"

    "<div style='display: flex; align-items: center;'>#{svg}#{legend_html}</div>".html_safe
  end
end
