using ColorSchemes
# col = map(i->ColorSchemes.Paired_12[((2*i)-1)],[4,3,2,1,5]);
# diagramcol = map(i->ColorSchemes.Paired_12[((2*i)-1)],[4,3,2,1,5]);
col = ColorSchemes.tab20[1:20];
# clear!(:diagramcol)
# clear!(diagramcol)
CPcol = ColorSchemes.tab20[1];
DPcol = ColorSchemes.tab20[2];
CEcol = ColorSchemes.tab20[8];
DEcol = ColorSchemes.tab20[6];
PEcol = ColorSchemes.tab20b[18];

diagramcol = Vector{RGB{Float64}}(undef,21);
diagramcol[1:18] = ColorSchemes.tab20[1:18];
diagramcol[19:21]=[PEcol,CEcol,DEcol];
# diagramcol[20] = ColorSchemes.tab20b[1];
# diagramcol[21] = ColorSchemes.tab20[20];



karma2col = Vector{RGB{Float64}}(undef,21);
karma2col[1:2]=[CPcol,DPcol]
karma2col[3:18] = ColorSchemes.tab20b[1:16];
karma2col[4] = PEcol;
karma2col[6] = DEcol;
karma2col[19:21]=[PEcol,CEcol,DEcol];
for idx in [3,6,7,10,11,14,15,18]
    karma2col[idx]=diagramcol[idx];
end

arrowcol = ColorSchemes.Paired_12[10];

neutcol = Gray[.8];

# mycolors = reshape(diagramcol,1,length(diagramcol));

# mycolors = Dict(
#     1=>reshape(diagramcol,1,length(diagramcol)),
#     2=>reshape(karma2col,1,length(karma2col)),
#     3=>reshape(karma2col,1,length(karma2col))
# );

mycolors = Dict(
    1=>diagramcol,
    2=>karma2col,
    3=>karma2col
);

# mycompstatcolors = reshape(append!([col[1],col[4],col[3]],neutcol),1,4);
mycompstatcolors = reshape(append!([CPcol,CEcol,PEcol],neutcol),1,4);
# dedump=dump.(diagramcol);
# dedump=dump.(mycolors[1]);
# dedump=dump.(mycolors[2]);
# dedump=dump.(mycolors[3]);
# to copy in LaTeX file
# colmat = 255*transpose(reshape(reinterpret(Float64,diagramcol),3,length(diagramcol)));