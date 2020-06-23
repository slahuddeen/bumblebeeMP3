function  player()
%PLAYER Summary of this function goes here
%   Detailed explanation goes here

temp = uigetfile({"*.wav";"*.mp4"})
[y,Fs] = audioread(temp);


end

