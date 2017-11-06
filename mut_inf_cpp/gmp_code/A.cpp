	#include <iostream>
	#include <iomanip>
	#include <algorithm>
	#include <utility>
	#include <vector>
	#include <cmath>
	#include <cassert>
	// #include <gmpxx.h>
	#include <gmp.h>
	#include <mpfr.h>
	#include "real.hpp"

	using namespace std;

	const int FLOAT_PREC = 2000;
	const int MAX_M = 15;
	
	typedef vector<int> vi;
	typedef vector<double> vd;
	typedef pair<int, int> pii;
	typedef pair<double, int> pdi;
	// typedef pair<double, double> pdd;
	typedef mpfr::real<FLOAT_PREC> mpf;
	typedef pair<mpf, mpf> pmpf;
	typedef vector<mpf> vmpf;
	typedef vector<pii> vpii;
	typedef vector<vi> vvi;

	/* Want to calculate I(X; Y | L_n) =
	H(Y|L_n=0) - sum_{x = 0,1} p_x H(Y|X = x,L_n=0).
	*/

	class MutInfCalculator {
		public:
			MutInfCalculator(vd, int, vpii);
			mpf p[2][1<<MAX_M];
			int e1[MAX_M];
			int e2[MAX_M];
			int num_edges;
			mpf Q[2][2][2];
			mpf calculated_mut_inf;
			mpf get_mut_inf();
			
		private:
			int get_bit(int, int);
			void clear_states();
			void add_vstate(int);
			mpf eval_state(int, int);
			pmpf calc_entropy(vmpf);
			vmpf get_all_v0_estates(int);
			vmpf get_all_estates();
	};

	 MutInfCalculator::MutInfCalculator(vd err, int n, vpii edge_list) {	 
		// cerr << err[0] << " " << err[1] << " " << n << endl;
		 if(n == 1) {
			 calculated_mut_inf = 1;
			 return;
		 }
		 
		for(int i = 0; i < 2; i++) {
			for(int j = 0; j < 2; j++) {                                         
				for(int k = 0; k < 2; k++) {
					int eq = 1;
					if(i != j) eq = 0;                                       
					if(k == eq) {                                             
						Q[i][j][k] = 1 - err[eq];
					}
					else {
						Q[i][j][k] = err[eq];
					}
					// cout << i << j << k << " " << Q[i][j][k] << endl;
				}
			}                                                           
		}
		
		num_edges = edge_list.size();
		assert(num_edges <= MAX_M);
		
		for(int i = 0; i < num_edges; i++) {
			e1[i] = edge_list[i].first;
			e2[i] = edge_list[i].second;
		}
		
		// Calculate the probability distribution.
		clear_states();
		// v_n = 0, wlog.
		for(int i = 0; i < (1<<(n-1)); i++) {
			add_vstate(i);
		}
		
		// Create the 
		pmpf tot_ent = calc_entropy(get_all_estates());
		pmpf ent0 = calc_entropy(get_all_v0_estates(0));
		pmpf ent1 = calc_entropy(get_all_v0_estates(1));
		
		mpf hy = tot_ent.second;
		mpf hyIx0 = (ent0.second * ent0.first + ent1.second * ent1.first) / tot_ent.first;
		
	/*	cout << tot_ent.first << " " << tot_ent.second << endl;
		cout << ent0.first << " " << ent0.second << endl;
		cout << ent1.first << " " << ent1.second << endl;
		
		cout << hy << endl;
		cout << hyIx0 << endl;
		cout << (hy - hyIx0) << endl; */
		calculated_mut_inf = hy - hyIx0;
	 }
		int MutInfCalculator::get_bit(int val, int i) {
			// Return ith bit of val.
			return (val >> i) % 2; 
		}

		void MutInfCalculator::clear_states() {
			for(int i = 0; i < (1<<num_edges); i++) {
				p[0][i] = 0;
				p[1][i] = 0;
			}
		}

		mpf MutInfCalculator::eval_state(int vstate, int estate) {
			mpf w = 1;
			for(int i = 0; i < num_edges; i++) {
		//		cout << "Edge " << i << " contrib" << endl;
				int u = e1[i]; int v = e2[i];
				int us = get_bit(vstate, u);
				int vs = get_bit(vstate, v);
				int es = estate % 2;
				w *= Q[us][vs][es];
				estate = estate >> 1;
			}
		//	cout << "Weight: " << w << endl;
			return w;
		}

		void MutInfCalculator::add_vstate(int i) {
		//	cout << "Adding: " << i << endl;
			int v0 = get_bit(i,0);
			for(int j = 0; j < (1<<num_edges); j++) {
				p[v0][j] += eval_state(i,j);
			}
			return;
		}


		pmpf MutInfCalculator::calc_entropy(vmpf a) {
			mpf norm = 0;
			mpf h = 0;
			for(int i = 0; i < a.size(); i++) {
				mpf tp = a[i];
				// cout << tp << endl;
				if(tp == 0) continue;
				norm += tp;
				h +=  tp * log2(tp);
			}
			h = h / norm;
			h = h - log2(norm);
			return pmpf(norm,-h);
		}

		vmpf MutInfCalculator::get_all_v0_estates(int v0) {
			vmpf a;
			for(int i = 0; i < (1 << num_edges); i++) {
				a.push_back(p[v0][i]);	
			}
			return a;
		}

		vmpf MutInfCalculator::get_all_estates() {
			vmpf a = get_all_v0_estates(0);
			vmpf a2 = get_all_v0_estates(1);
			for(int i = 0; i < a.size(); i++) {
				a[i] += a2[i];
			}
			return a;
		}

		mpf MutInfCalculator::get_mut_inf() {
			return calculated_mut_inf;
		}


	int main() {
		double a = 2.2;
		double b = -sqrt(4*a + 1) + a + 1;
		double N = 100;
		
		vd e(2,0);
		e[0] = 1-a/N;
		e[1] = b/N;
		cin >> e[0] >> e[1];	
//	for(e[0] = 0; e[0] <= 1; e[0] += 0.02) {
	//		cerr << e[0] << endl;
	//		for(e[1] = 0; e[1] <= 1; e[1] += 0.02) {

			mpf tot_mut_inf = 0;
			vpii tmp_edge;
			int n = 10;
			mpf fac = 1;
			for(int i = 0; i < n; i++) {
				
				MutInfCalculator temp_calc(e, i+1, tmp_edge);
				mpf temp_mut_inf = temp_calc.get_mut_inf();
				cout << e[0] << "," << e[1] << "," << temp_mut_inf << "," << i << endl;
		//		tot_mut_inf += temp_mut_inf * fac;
				tmp_edge.push_back(pii(i,i+1));
				if(i != 0) {
					fac = fac * (N-i);
				}
			}
			// cout << tot_mut_inf;
	//		}
	//	}
		
		return 0;

	}
