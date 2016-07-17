defmodule PSITest do
  use ExUnit.Case
  doctest PSI

  test "parse new style" do
    input = """
    <tr>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSIDate">1am</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSINorth">55</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSISouth">52</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSIEast">52</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSIWest">54</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSICentral">52</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive_ctrl0_LblPSIOverall">52-55</span></center>
                        </td>
                    </tr>
                    """

    [datetime, north, south, east, west, central] = PSI.Parser.parse_tr(~D[2000-01-22], input)
    assert datetime == "2000-01-22 01:00"
    assert north == "55"
    assert south == "52"
    assert east == "52"
    assert west == "54"
    assert central == "52"
  end

  test "old style, success" do
    input = """
    <td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSIDate">4pm</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSINorth">40</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSISouth">36</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSIEast">25</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSIWest">35</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSICentral">32</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPSIOverall">25-40</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPM25North">-</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPM25South">-</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPM25East">-</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPM25West">-</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPM25Central">-</span></center>
</td>
<td>
    <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl15_LblPM25Overall">-</span></center>
</td>
</tr>
    """
    [datetime, north, south, east, west, central] = PSI.Parser.parse_tr(~D[2000-01-22], input)
    assert datetime == "2000-01-22 16:00"
    assert north == "40"
    assert south == "36"
    assert east == "25"
    assert west == "35"
    assert central == "32"
  end
  
  test "old style, ignore fail" do
    input = """
    <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSIDate">1am</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSINorth">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSISouth">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSIEast">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSIWest">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSICentral">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPSIOverall">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPM25North">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPM25South">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPM25East">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPM25West">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPM25Central">-</span></center>
                        </td>
                        <td>
                            <center><span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchiveFull_ctrl0_LblPM25Overall">-</span></center>
                        </td>
                    </tr>
    """
    result = PSI.Parser.parse_tr(Timex.today, input)
    assert result == []
  end
end
