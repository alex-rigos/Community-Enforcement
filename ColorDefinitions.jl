using ColorSchemes
col = ColorSchemes.tab20[1:20];

# Colours for different strategies
CPcol = ColorSchemes.tab20[1];
DPcol = ColorSchemes.tab20[2];
CEcol = ColorSchemes.tab20[8];
DEcol = ColorSchemes.tab20[6];
PEcol = ColorSchemes.tab20b[18];

# Colours for karma 1 (CE standard of behaviour)
diagramcol = Vector{RGB{Float64}}(undef,21);
diagramcol[1:18] = ColorSchemes.tab20[1:18];
diagramcol[19:21]=[PEcol,CEcol,DEcol];

# Colours for karma 2 (PE standard of behaviour)
karma2col = Vector{RGB{Float64}}(undef,21);
karma2col[1:2]=[CPcol,DPcol]
karma2col[3:18] = ColorSchemes.tab20b[1:16];
karma2col[4] = PEcol;
karma2col[6] = DEcol;
karma2col[19:21]=[PEcol,CEcol,DEcol];

# Set the same colour for strategies that behave the same under both standards (i.e., that do not condition behaviour on opponent's standing)
for idx in [3,6,7,10,11,14,15,18]
    karma2col[idx]=diagramcol[idx];
end

# Assign the colours to the different karma (standard of behaviour) regimes (karma 3 uses only strategies in entries 17-21)

mycolors = Dict(
    1=>diagramcol,
    2=>karma2col,
    3=>karma2col
);

# Colour for vector field diagrams
arrowcol = ColorSchemes.Paired_12[10];

# Colour for share of producers
neutcol = Gray[.8];

# Colours for comparative statics diagrams
mycompstatcolors = reshape(append!([CPcol,CEcol,PEcol],neutcol),1,4);