// OnyxChart Component
// This component provides a visualization for analytics data using line graphs.

import React from 'react';
import { Line } from 'react-chartjs-2';

const OnyxChart = ({ data, options }) => {
  return (
    <div>
      <Line data={data} options={options} />
    </div>
  );
};

export default OnyxChart;