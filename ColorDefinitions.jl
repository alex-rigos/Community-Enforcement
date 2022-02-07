col = map(i->ColorSchemes.Paired_12[((2*i)-1)],[4,3,2,1,5]);
diagramcol = map(i->ColorSchemes.Paired_12[((2*i)-1)],[4,3,2,1,5]);
# col = map(i->ColorSchemes.Paired_12[((2*i))],1:5)

arrowcol = ColorSchemes.Paired_12[10];

neutcol = Gray[.8];

mycolors = reshape(col,1,5);
mycompstatcolors = reshape(append!(col[1:2],neutcol),1,3);
dedump=dump.(diagramcol);
# to copy in LaTeX file
# colmat = 255*transpose(reshape(reinterpret(Float64,diagramcol),3,length(diagramcol)));