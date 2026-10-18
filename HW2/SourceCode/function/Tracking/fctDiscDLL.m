function mError = fctDiscDLL(mZ)
    %% Columns: normalized envelope, power, coherent dot product.
    %% E/P/L offset is 0.5 chip; positive output = estimated delay - true delay.
    
    vE = abs(mZ(:,1)); vL = abs(mZ(:,3)); vP = mZ(:,2);
    
    mError = [0.5*(vE-vL)./max(vE+vL,eps), ...
              0.25*(vE.^2-vL.^2)./max(vE.^2+vL.^2,eps), ...
              real((mZ(:,1)-mZ(:,3)).*conj(vP))/2];
end
