%one way and two way slab design 

  clc;
  clear;
  
  %Load the input file 
  load slab.mat
  load tables.mat
  load bending_coeff.mat
  
  %Ratio of longer span to shorter span 
  ratio=slab.width/slab.length
  
  if ratio>=2
    disp("one way slab")
    run slab_design.m
  else 
    disp("two way slab")
    run two_way_slab.m
  end
  