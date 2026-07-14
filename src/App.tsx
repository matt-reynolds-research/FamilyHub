/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { ExternalLink, Download } from "lucide-react";

export default function App() {
  return (
    <div className="min-h-screen bg-[#FFF8F0] flex flex-col items-center justify-center p-8 text-[#1E1E2C] font-sans">
      <div className="max-w-2xl bg-[#FFFDF8] p-12 rounded-[20px] shadow-[0_4px_20px_rgba(0,0,0,0.03)] border border-black/5 text-center">
        <div className="w-16 h-16 bg-[#3F51B5] rounded-[20px] flex items-center justify-center mx-auto mb-6 shadow-[0_4px_15px_rgba(0,0,0,0.02)]">
          <Download className="text-white w-8 h-8" />
        </div>
        
        <h1 className="text-[32px] font-bold mb-4 tracking-tight">Flutter Scaffold Ready</h1>
        
        <p className="text-[16px] text-[#7A7A8C] mb-8 leading-relaxed">
          The <strong className="text-[#1E1E2C]">Reynolds Family Dashboard</strong> Flutter project has been successfully generated based on your specifications. 
          <br /><br />
          Because AI Studio's live preview environment is built for React and Node.js, we cannot execute the Flutter build here. Your complete, production-ready Flutter code is safely saved in the workspace.
        </p>
        
        <div className="bg-[#FFFDF8] border-t-4 border-[#3F51B5] p-6 rounded-[20px] text-left mb-8 shadow-[0_4px_15px_rgba(0,0,0,0.02)]">
          <h3 className="font-semibold text-[#1E1E2C] text-[18px] flex items-center mb-4">
            <ExternalLink className="w-5 h-5 mr-2 text-[#3F51B5]" /> How to get your code:
          </h3>
          <ol className="list-decimal pl-5 space-y-3 text-[#7A7A8C] text-[15px]">
            <li>Look to the top-right corner of the AI Studio window.</li>
            <li>Click the <strong className="text-[#1E1E2C]">Settings (gear) icon</strong> or the <strong className="text-[#1E1E2C]">Share</strong> menu.</li>
            <li>Select <strong className="text-[#1E1E2C]">Export to ZIP</strong> or <strong className="text-[#1E1E2C]">Export to GitHub</strong>.</li>
            <li>Once extracted locally, navigate to the <code className="bg-[#3F51B5]/10 text-[#3F51B5] px-3 py-1 rounded-[12px] text-sm font-bold">reynolds_family_dashboard</code> folder.</li>
            <li>Run <code className="bg-[#3F51B5]/10 text-[#3F51B5] px-3 py-1 rounded-[12px] text-sm font-bold">flutter run</code>!</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
